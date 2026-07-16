import { LightningElement, api } from 'lwc';

export default class FlightResultCard extends LightningElement {
    // Binds structural object mappings passed downwards from iteration loops [Doc: 12.1]
    @api flightOffer = {};

    // Transform raw ISO string objects into clean, locale-aware time indicators
    get formattedDepartureTime() {
        if (!this.flightOffer.departureTime) return '';
        return new Date(this.flightOffer.departureTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    get formattedArrivalTime() {
        if (!this.flightOffer.arrivalTime) return '';
        return new Date(this.flightOffer.arrivalTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    // Handles user button triggers and bubbles selected offer metadata back to parent flows
    handleTicketSelection() {
        const selectTicketEvent = new CustomEvent('selectflight', {
            detail: {
                offerId: this.flightOffer.offerId,
                expectedPrice: this.flightOffer.price
            }
        });
        this.dispatchEvent(selectTicketEvent);
    }
}
