import { LightningElement, api } from 'lwc';


export default class FlightResultsList extends LightningElement {
    // Exposes a public property to pass search result matrices from the parent shell [Doc: 12.1]
    @api flightOffers = [];

    // Evaluates array length properties dynamically to handle layout flags
    get hasResults() {
        return this.flightOffers && this.flightOffers.length > 0;
    }

    // Listens to child ticket card actions and bubbles events upwards to the parent container
    handleFlightSelectionForwarding(event) {
        const selectFlightForwardEvent = new CustomEvent('selectflight', {
            detail: event.detail
        });
        this.dispatchEvent(selectFlightForwardEvent);
    }
}
