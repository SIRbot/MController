/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implement the view controller that allows the user
		to host a game and discover peers.
*/

import UIKit
import Network

class PeerListViewController: UITableViewController {

	var results: [NWBrowser.Result] = [NWBrowser.Result]()
	var passcode: String = ""
    var deviceName: String = NSFullUserName()

	var sections: [GameFinderSection] = [.join]

	enum GameFinderSection {
		case join
	}

	func resultRows() -> Int {
		if results.isEmpty {
			return 1
		} else {
			return min(results.count, 6)
		}
	}

	// Generate a new random passcode when the app starts hosting games.
	func generatePasscode() -> String {
        return String("\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

        // Listen immediately upon startup.
        applicationServiceListener = PeerListener(delegate: self)

		// Generate a new passcode.
		passcode = generatePasscode()

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "deviceCell")
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let passcodeVC = segue.destination as? PasscodeViewController {
			passcodeVC.browseResult = sender as? NWBrowser.Result
			passcodeVC.peerListViewController = self
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultRows()
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") ?? UITableViewCell(style: .default, reuseIdentifier: "deviceCell")
        // Display the results, if any. Otherwise, show "searching..."
        if sharedBrowser == nil {
            cell.textLabel?.text = "Search for devices"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemCyan
        } else if results.isEmpty {
            cell.textLabel?.text = "Searching for devices..."
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .systemCyan
        } else {
            let peerEndpoint = results[indexPath.row].endpoint
            if case let NWEndpoint.service(name: deviceName, type: _, domain: _, interface: _) = peerEndpoint {
                cell.textLabel?.text = deviceName
            } else {
                cell.textLabel?.text = "Unknown Endpoint"
            }
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .systemCyan
        }
        return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sharedBrowser == nil {
            print("init shared browser")
            sharedBrowser = PeerBrowser(delegate: self)
        } else if !results.isEmpty {
            // Handle the user tapping a discovered game.
            let result = results[indexPath.row]
            performSegue(withIdentifier: "showPasscodeSegue", sender: result)
        }

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension PeerListViewController: PeerBrowserDelegate {
	// When the discovered peers change, update the list.
	func refreshResults(results: Set<NWBrowser.Result>) {
		self.results = [NWBrowser.Result]()
		for result in results {
			if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint {
				if name != self.deviceName {
					self.results.append(result)
				}
			}
		}
		tableView.reloadData()
	}

	// Show an error if peer discovery fails.
	func displayBrowseError(_ error: NWError) {
		var message = "Error \(error)"
		if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_NoAuth)) {
			message = "Not allowed to access the network"
		}
		let alert = UIAlertController(title: "Cannot discover other players",
									  message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
}

extension PeerListViewController: PeerConnectionDelegate {
	// When a connection becomes ready, move into game mode.
	func connectionReady() {
		navigationController?.performSegue(withIdentifier: "showMainSegue", sender: nil)
	}

	// When the you can't advertise a game, show an error.
	func displayAdvertiseError(_ error: NWError) {
		var message = "Error \(error)"
		if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_NoAuth)) {
			message = "Not allowed to access the network"
		}
		let alert = UIAlertController(title: "Cannot host game",
									  message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}

	// Ignore connection failures and messages prior to starting a game.
	func connectionFailed() { }
	func receivedMessage(content: Data?, message: NWProtocolFramer.Message) { }
}
