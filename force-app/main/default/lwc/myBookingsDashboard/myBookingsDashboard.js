import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import flightCancellationChannel from '@salesforce/messageChannel/FlightCancellationChannel__c';
import getConfirmedBookingsByAgent from '@salesforce/apex/BookingDataController.getConfirmedBookingsByAgent';

export default class MyBookingsDashboard extends NavigationMixin(LightningElement) {
    @track bookingsList = []; @track isModalOpen = false; @track targetBookingId = '';
    wiredBookingsResult;

    // Load Message Context interface parameters for LMS transmissions
    @wire(MessageContext) messageContext;

    // Wired database pipe tracking Section 8.4 Server controllers [8.4]
    @wire(getConfirmedBookingsByAgent)
    wiredData(result) {
        this.wiredBookingsResult = result;
        if (result.data) { this.bookingsList = result.data; }
    }

    refreshQueueData() { return refreshApex(this.wiredBookingsResult); }

    navigateToRecord(e) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId: e.target.dataset.id, actionName: 'view' }
        });
    }

    handleOpenModal(e) { this.targetBookingId = e.target.dataset.id; this.isModalOpen = true; }
    handleCloseModal() { this.isModalOpen = false; }

    handleConfirmCancellation() {
        this.isModalOpen = false;
        
        // Broadcast the cancellation status payload across the platform via LMS Channel Node [Doc: 12.1]
        publish(this.messageContext, flightCancellationChannel, {
            bookingId: this.targetBookingId,
            status: 'Cancelled'
        });
        
        this.refreshQueueData();
    }
}
