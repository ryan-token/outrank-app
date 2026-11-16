//
//  RankingTableHeaderPinTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct RankingTableHeaderPinTests {
    /// A pin whose line is 100 points down the screen.
    private func makePin() -> RankingTableHeaderPin {
        let pin = RankingTableHeaderPin()
        pin.pinLine = 100
        return pin
    }

    @Test func headingsPinOnceTheyCrossTheLineAndUnpinWhenTheyComeBack() {
        let pin = makePin()

        pin.headingsMoved(to: 400)
        #expect(!pin.isPinned)

        pin.listScrolled(to: 301)
        pin.headingsMoved(to: 99)
        #expect(pin.isPinned)

        pin.listScrolled(to: 300)
        pin.headingsMoved(to: 100)
        #expect(!pin.isPinned)
    }

    // The row is the one that knows where it is: a scroll position that arrives before
    // the row has said where it moved to doesn't speak for it.
    @Test func rowOnScreenIsBelievedOverTheScrollPosition() {
        let pin = makePin()
        pin.headingsMoved(to: 400)

        pin.listScrolled(to: 350)
        #expect(!pin.isPinned)
    }

    // A jump down the table, by the scroll indicator say, drops the row before it can
    // report crossing the line.
    @Test func headingsDroppedInOneJumpPastTheLineStillPin() {
        let pin = makePin()
        pin.headingsMoved(to: 400)

        pin.listScrolled(to: 5_000)
        pin.headingsLeftScreen()
        #expect(pin.isPinned)

        pin.listScrolled(to: 0)
        #expect(!pin.isPinned)
    }

    @Test func headingsThatWereNeverOnScreenDoNotPin() {
        let pin = makePin()

        pin.listScrolled(to: 5_000)
        #expect(!pin.isPinned)
    }

    @Test func movingTheLineIsAnsweredWhileTheRowIsAway() {
        let pin = makePin()
        pin.headingsMoved(to: 400)
        pin.headingsLeftScreen()
        pin.listScrolled(to: 250)
        #expect(!pin.isPinned)

        pin.pinLine = 160
        #expect(pin.isPinned)
    }
}
