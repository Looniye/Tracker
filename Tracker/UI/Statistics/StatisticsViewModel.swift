final class StatisticsViewModel {
    var onTrackersChange: (([TrackerRecord]) -> Void)?
    
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [TrackerRecord] = [] {
        didSet {
            onTrackersChange?(trackers)
        }
    }
    
    func viewWillAppear() {
        guard let trackers = try? trackerRecordStore.loadCompletedTrackers() else { return }
        self.trackers = trackers
    }
}
