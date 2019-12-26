namespace Notifications {

	export enum SeverityType {
		"INFO" = 101,
		"GOOD" = 102,
		"BAD" = 103,
		"WARNING" = 104
	}

	class Message {

		public text: string;
		public type: SeverityType;
		public loading: boolean;
		public time: number;

		constructor(message: string, type: SeverityType, loading: boolean, time: number) {
			this.text = message;
			this.type = type;
			this.loading = loading;
			this.time = time;

			return Object.freeze(this);
		}
	}

	export class NotificationManager {

		private defaultTime: number;
		private anchor: HTMLElement;
		private active: boolean = false;
		private notificationQueue: Message[];

		constructor(anchor: HTMLElement, defaultTime: number) {
			this.anchor = anchor;
			this.defaultTime = defaultTime;
			Object.defineProperty(this, "anchor", {value: anchor});
			Object.defineProperty(this, "defaultTime", {value: defaultTime});
			Object.defineProperty(this, "notificationQueue", {value: []});

			return Object.seal(this);
		}
		
		push(message: string, type: SeverityType, loading: boolean, time: number): void {
			this.notificationQueue.push(new Message(message, type, loading, time || this.defaultTime));

			if (this.active) return;
			this.process();
		}

		process(): void {
			this.anchor.classList.add("hidden");

			if (!this.notificationQueue.length) {
				this.active = false;
				return;
			}


		}

		createAndDisplay(message: Message): Promise<Function> {
			return new Promise(function(resolve, reject) {

				this.anchor.innerText = message.text;
				this.anchor.classList.remove("info, good, bad, warning");
				this.anchor.classList.add(Notifications.SeverityType[message.type].toLowerCase());
				// LOADING
				this.anchor.classList.remove("hidden");

				setTimeout(this.process, message.time);
			});
		}
	}
};