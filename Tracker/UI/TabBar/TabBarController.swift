import UIKit

final class TabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tabBar.isTranslucent = false
		tabBar.backgroundColor = .white
		tabBar.tintColor = .blue
		
		let trackerStore = TrackerStore()
		let trackersViewController = TrackersViewController(trackerStore: trackerStore)
		let statisticsViewController = StatisticsViewController()
		let statisticsViewModel = StatisticsViewModel()
		statisticsViewController.statisticsViewModel = statisticsViewModel
		
		trackersViewController.tabBarItem = UITabBarItem(
			title: L10n.Tabbar.trackers,
			image: UIImage(systemName: "record.circle.fill"),
			selectedImage: nil
		)
		statisticsViewController.tabBarItem = UITabBarItem(
			title: L10n.Tabbar.statistics,
			image: UIImage(systemName: "hare.fill"),
			selectedImage: nil
		)
		
		let controllers = [trackersViewController, statisticsViewController]
		
		viewControllers = controllers
	}
}
