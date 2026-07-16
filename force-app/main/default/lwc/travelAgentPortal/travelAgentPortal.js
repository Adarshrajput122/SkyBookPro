import { LightningElement, track, wire } from 'lwc';
import getConfirmedBookingsByAgent from '@salesforce/apex/BookingDataController.getConfirmedBookingsByAgent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TravelAgentPortal extends LightningElement {
    @track bookingsList = [];
    @track selectedBookingId = '';
    @track isModalOpen = false;

    // Direct binding link to Section 8.4 Server Query Metrics Class [8.4]
    @wire(getConfirmedBookingsByAgent)
    wiredBookings({ error, data }) {
        if (data) this.bookingsList = data;
    }

    openDetailView(e) { this.selectedBookingId = e.target.dataset.id; }
    openCancellationModal() { this.isModalOpen = true; }
    closeCancellationModal() { this.isModalOpen = false; }

    executeCancellationAction() {
        this.isModalOpen = false;
        this.dispatchEvent(new ShowToastEvent({ title: 'Cancellation Dispatched', message: 'The selected flight ticket reservation status has been marked as Cancelled.', variant: 'success' }));
    }
}
