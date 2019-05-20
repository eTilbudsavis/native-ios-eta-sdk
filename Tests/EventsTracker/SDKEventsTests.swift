//
//  ┌────┬─┐         ┌─────┐
//  │  ──┤ └─┬───┬───┤  ┌──┼─┬─┬───┐
//  ├──  │ ╷ │ · │ · │  ╵  │ ╵ │ ╷ │
//  └────┴─┴─┴───┤ ┌─┴─────┴───┴─┴─┘
//               └─┘
//
//  Copyright (c) 2018 ShopGun. All rights reserved.

import XCTest
@testable import ShopGunSDK

class SDKEventsTests: XCTestCase {
    // https://gist.github.com/tbug/88c169d2ac5f5bebbf59211eb35ff23a
    var tokenizer: UniqueViewTokenizer!
    fileprivate let dataStore = MockSaltDataStore()
    
    override func setUp() {
        super.setUp()
        
        self.tokenizer = UniqueViewTokenizer(salt: "salty")!
        
        dataStore.salt = "myhash"
        guard let settings = try? Settings.EventsTracker(appId: "appId_123") else { return }
        EventsTracker.configure(settings,
                                dataStore: self.dataStore)
    }
    
    func testDummy() {
        let testDate = Date(eventTimestamp: 12345)
        
        let event = Event.dummy(timestamp: testDate)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 0)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload, [:])
        
        let nowTimestamp = Date().eventTimestamp
        XCTAssert(abs(Event.dummy().timestamp.eventTimestamp - nowTimestamp) <= 2)
    }
    
    func testPagePublicationOpened() {
        let testDate = Date(eventTimestamp: 12345)
        let event = Event.pagedPublicationOpened("pub1", timestamp: testDate, tokenizer: self.tokenizer.tokenize)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 1)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload,
                       ["pp.id": .string("pub1"),
                        "vt": .string("HUdC076YIL8=")])
        
        let nowTimestamp = Date().eventTimestamp
        let defaultEvent = Event.pagedPublicationOpened("😁")
        XCTAssert(abs(defaultEvent.timestamp.eventTimestamp - nowTimestamp) <= 2)
        XCTAssertEqual(defaultEvent.payload,
                       ["pp.id": .string("😁"),
                        "vt": .string("POcLWv7/N4Q=")])
    }
    
    func testPagedPublicationPageOpened() {
        let testDate = Date(eventTimestamp: 12345)
        let event = Event.pagedPublicationPageOpened("pub1", pageNumber: 1, timestamp: testDate, tokenizer: self.tokenizer.tokenize)

        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 2)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload,
                       ["pp.id": .string("pub1"),
                        "ppp.n": .int(1),
                        "vt": .string("xX+BAiu1Nmo=")])

        let nowTimestamp = Date().eventTimestamp
        let defaultEvent = Event.pagedPublicationPageOpened("ølØl5Banana", pageNumber: 9999)
        XCTAssert(abs(defaultEvent.timestamp.eventTimestamp - nowTimestamp) <= 2)
        XCTAssertEqual(defaultEvent.payload,
                       ["pp.id": .string("ølØl5Banana"),
                        "ppp.n": .int(9999),
                        "vt": .string("JR8kZFk7M+Y=")])
        
        XCTAssertEqual(Event.pagedPublicationPageOpened("pub1", pageNumber: 1).payload,
                       ["pp.id": .string("pub1"),
                        "ppp.n": .int(1),
                        "vt": .string("GKtJxfAxRZI=")])
        
        XCTAssertEqual(Event.pagedPublicationPageOpened("pub1", pageNumber: 9999).payload,
                       ["pp.id": .string("pub1"),
                        "ppp.n": .int(9999),
                        "vt": .string("VwMOrDD8zMk=")])
    }
    
    func testPotentialLocalBusinessVisit() {
        let testDate = Date(eventTimestamp: 12345)
        let event = Event.potentialLocalBusinessVisit(for: .init(rawValue: "e3dclwL"), dealerId: .init(rawValue: "d7fazg"), horizontalAccuracy: 93, distanceToStore: 85, timeSinceLastInteraction: 3600, timestamp: testDate)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 10)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        
        XCTAssertEqual(event.payload,
                       ["lb.id": .string("e3dclwL"),
                        "lb.bid": .string("d7fazg"),
                        "l.hac": .int(93),
                        "lb.dis": .int(85),
                        "b.cin": .bool(true),
                        "b.cint": .int(1),
                        "vt": .string("JGwLh2htW9c=")])
    }
    
    func testOfferOpened() {
        let testDate = Date(eventTimestamp: 12345)
        let event = Event.offerOpened("offer_123", timestamp: testDate, tokenizer: self.tokenizer.tokenize)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 3)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload,
                       ["of.id": .string("offer_123"),
                        "vt": .string("YNcV9px8d8U=")])
        
        let nowTimestamp = Date().eventTimestamp
        let defaultEvent = Event.offerOpened("øffer_321")
        XCTAssert(abs(defaultEvent.timestamp.eventTimestamp - nowTimestamp) <= 2)
        XCTAssertEqual(defaultEvent.payload,
                       ["of.id": .string("øffer_321"),
                        "vt": .string("ryYm+eb1bUU=")])
    }
    
    func testClientSessionOpened() {
        let testDate = Date(eventTimestamp: 12345)
        
        let event = Event.clientSessionOpened(timestamp: testDate)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 4)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload, [:])
        
        let nowTimestamp = Date().eventTimestamp
        XCTAssert(abs(Event.clientSessionOpened().timestamp.eventTimestamp - nowTimestamp) <= 2)
    }
    
    func testSearched() {
        let testDate = Date(eventTimestamp: 12345)
        let query = "Søme Very Long Séarch string 🌈"
        let event = Event.searched(for: query, languageCode: "DA", timestamp: testDate, tokenizer: self.tokenizer.tokenize)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 5)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload,
                       ["sea.q": .string(query),
                        "sea.l": .string("DA"),
                        "vt": .string("erHTNwqSrLY=")])
        
        let nowTimestamp = Date().eventTimestamp
        let defaultEvent = Event.searched(for: "", languageCode: nil)
        XCTAssert(abs(defaultEvent.timestamp.eventTimestamp - nowTimestamp) <= 2)
        XCTAssertEqual(defaultEvent.payload,
                       ["sea.q": .string(""),
                        "vt": .string("2oEIMMzybMM=")])
        
        XCTAssertEqual(Event.searched(for: "my search string", languageCode: "a").payload,
                       ["sea.q": .string("my search string"),
                        "sea.l": .string("a"),
                        "vt": .string("bNOIlf+nAAU=")])
        
        XCTAssertEqual(Event.searched(for: "my search string 😁", languageCode: nil).payload,
                       ["sea.q": .string("my search string 😁"),
                        "vt": .string("+OJqwh68nIk=")])
        
        XCTAssertEqual(Event.searched(for: "øl og æg", languageCode: nil).payload,
                       ["sea.q": .string("øl og æg"),
                        "vt": .string("NTgj68OWnbc=")])
    }
    
    func testOfferOpenedAfterSearch() {
        let testDate = Date(eventTimestamp: 12345)
        let query = "Søme Very Long Séarch string 🌈"
        let event = Event.offerOpenedAfterSearch(offerId: "offer_123", query: query, languageCode: "DA", timestamp: testDate)
        
        XCTAssertFalse(event.id.rawValue.isEmpty)
        XCTAssertEqual(event.type, 7)
        XCTAssertEqual(event.timestamp.eventTimestamp, 12345)
        XCTAssertEqual(event.version, 2)
        XCTAssertEqual(event.payload,
                       ["sea.q": .string(query),
                        "sea.l": .string("DA"),
                        "of.id": .string("offer_123")])
        
        let nowTimestamp = Date().eventTimestamp
        let defaultEvent = Event.offerOpenedAfterSearch(offerId: "abc123", query: "", languageCode: nil)
        XCTAssert(abs(defaultEvent.timestamp.eventTimestamp - nowTimestamp) <= 2)
        XCTAssertEqual(defaultEvent.payload,
                       ["sea.q": .string(""),
                        "of.id": .string("abc123")])
    }
}

fileprivate class MockSaltDataStore: ShopGunSDKDataStore {
    var salt: String? = nil
    
    func set(value: String?, for key: String) {
        guard key == "ShopGunSDK.EventsTracker.ClientId" else { return }
        salt = value
    }
    func get(for key: String) -> String? {
        guard key == "ShopGunSDK.EventsTracker.ClientId" else { return nil }
        return salt
    }
}
