import { LightningElement, api, track } from 'lwc';
import createBooking from '@salesforce/apex/BookingService.createBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookingConfirmation extends LightningElement {
    @api recordId; @api offerId; @api expectedPrice;
    @track isLoading = false;

    handleCheckoutExecute() {
        this.isLoading = true;
        
        // Executes rollback-protected backend DML transaction imperatively [8.3]
        createBooking({ contactId: this.recordId, offerId: this.offerId, expectedPrice: this.expectedPrice })
        .then((resultRecord) => {
            this.dispatchEvent(new ShowToastEvent({ title: 'Booking Confirmed!', message: `Ticket Reference PNR: ${resultRecord.Name}`, variant: 'success' }));
            this.dispatchEvent(new CustomEvent('bookingsuccess'));
        })
        .catch((error) => {
            // Graceful processing of database validation rule rejections or price shifts
            this.dispatchEvent(new ShowToastEvent({ title: 'Airline Reservation Failed', message: error.body.message, variant: 'error', mode: 'sticky' }));
        })
        .finally(() => { this.isLoading = false; });
    }
}
