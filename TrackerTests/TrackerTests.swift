import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

	func testTrackersViewControllerSnapshot() throws {
		let vc = TrackersViewController(trackerStore: StubTrackerStore())
		assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
	}
	
	func testTrackersViewControllerDarkSnapshot() throws {
		let vc = TrackersViewController(trackerStore: StubTrackerStore())
		assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
	}

}

extension TrackerTests {
	private struct StubTrackerStore: TrackerStoreProtocol {
		var delegate: TrackerStoreDelegate?
		
		private static let category = TrackerCategory(label: "Домашний уют")
		
		private static let trackers: [[Tracker]] = [
			[
				Tracker(
					label: "Поливать растения",
					emoji: "❤️",
					color: .selection[4],
					category: category,
					completedDaysCount: 10,
					schedule: [.saturday],
					isPinned: true
				)
			],
			[
				Tracker(
					label: "Кошка заслонила камеру на созвоне",
					emoji: "😻",
					color: .selection[1],
					category: category,
					completedDaysCount: 2,
					schedule: nil,
					isPinned: false
				),
				Tracker(
					label: "Бабушка прислала открытку в вотсапе",
					emoji: "🌺",
					color: .selection[0],
					category: category,
					completedDaysCount: 1,
					schedule: nil,
					isPinned: false
				)
			]
		]
		
		var numberOfTrackers: Int = 3
		
		var numberOfSections: Int = 2
		
		func loadFilteredTrackers(date: Date, searchString: String) throws {}
		
		func numberOfRowsInSection(_ section: Int) -> Int {
			switch section {
			case 0: return 1
			case 1: return 2
			default: return 0
			}
		}
		
		func headerLabelInSection(_ section: Int) -> String? {
			switch section {
			case 0: return "Закрепленные"
			case 1: return StubTrackerStore.category.label
			default: return nil
			}
		}
		
		func tracker(at indexPath: IndexPath) -> Tracker? {
			let tracker = StubTrackerStore.trackers[indexPath.section][indexPath.item]
			return tracker
		}
		
		func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {}
		
		func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {}
		
		func deleteTracker(_ tracker: Tracker) throws {}
		
		func togglePin(for tracker: Tracker) throws {}
		
	}
}
