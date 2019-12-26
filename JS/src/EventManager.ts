namespace Events {

	interface SubscriberList {
		[key: number]: Map<number, Subscriber>
	}

	export enum Types {
		"PLACEHOLDER1" = 201,
		"PLACEHOLDER2" = 202,
		"PLACEHOLDER3" = 203
	}

	export class EventManager {

		subscribers: SubscriberList;

		constructor() {
			this.subscribers = {};
			return Object.freeze(this);
		}

		subscribe(type: Types, callback: Function, context: Object): boolean {
			if (!this.subscribers[type])
				this.subscribers[type] = new Map();

			let newSubscriber = new Subscriber(callback, context);
			this.subscribers[type].set(newSubscriber.id, newSubscriber);

			return true;
		}

		unsubscribe(type: Types, id: number): boolean {
			return this.subscribers[type].delete(id);
		}

		dispatch(event: Event): boolean {
			if (!this.subscribers[event.type].size) return false;

			this.subscribers[event.type].forEach(subscriber =>
				subscriber.callback.apply(subscriber.context, event.data)
			);

			return true;
		}

		trigger(type: Types, data: Object): boolean {
			return this.dispatch(new Event(type, data));
		}
	}

	class Subscriber {

		readonly callback: Function;
		readonly id: number = Date.now() - Math.random() * 100;
		readonly context: Object;
		readonly timeStamp: number = performance.now();

		constructor(callback: Function, context: Object) {
			this.callback = callback;
			this.context = context;

			return Object.freeze(this);
		}
	}

	class Event {

		readonly type: Types;
		readonly timeStamp = performance.now();
		readonly data: Object;

		constructor(type: Types, data: Object) {
			this.type = type;
			this.data = data;

			return Object.freeze(this);
		}
	}
}