namespace amp {

	export function init(): void {

		const request = new Request("Assets/clientIndex.json", {
			method: "GET",
			headers: new Headers({
				"Accept": "application/json"
			})
		});

		fetch(request).then(response => {
			if (response.status !== 200)
				throw new Error(`Failed to fetch client index. Server responded with ${response.status}`);

			return response.json();
		})
		.then(jsonResponse=> {
			console.log(Object.keys(jsonResponse.tracks).length);
		});

		const serviceList = new Map();
		serviceList.set("events", new Events.EventManager());
		serviceList.set("eventTypes", Events.Types)
		serviceList.set("notifications", new Notifications.NotificationManager( document.querySelector("#NotificationMessage"), 2000 ));
		serviceList.set("notificationTypes", Notifications.SeverityType)

		const services = new ServiceLocator(serviceList);
		console.log(services);
	}

};