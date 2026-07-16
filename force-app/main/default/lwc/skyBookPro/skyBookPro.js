import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { MessageContext, publish } from 'lightning/messageService';
import flightCancellationChannel from '@salesforce/messageChannel/FlightCancellationChannel__c';

// Import mandatory backend services [8.3, 14.1]
import searchFlights from '@salesforce/apex/DuffelFlightSearchService.searchFlights';
import createBooking from '@salesforce/apex/BookingService.createBooking';

export default class SkyBookApp extends LightningElement {
    @api recordId; // Injects Contact record ID automatically

    @track currentViewStage = 'search'; // Core stage views flags: 'search', 'checkout', 'success'
    @track discoveredOffersCatalog = [];
    @track isLoading = false;

    // Active tracking records payload variables
    @track activeOfferId = '';
    @track activeExpectedPrice = 0;
    @track activePassengerCount = 1;
    @track generatedPnrCode = '';

    @wire(MessageContext) messageContext;

    // Tracks stage view visibility states reactively [Doc: 12.1]
    get displaySearchStage() { return this.currentViewStage === 'search'; }
    get displayCheckoutStage() { return this.currentViewStage === 'checkout'; }
    get displaySuccessStage() { return this.currentViewStage === 'success'; }

    // STEP 1: Handlers search execution and fetches arrays live from Duffel [8.3]
    handleOutboundFlightSearchRequest(event) {
        if (!event || !event.detail) return;
        this.isLoading = true;
        
        const criteria = event.detail;
        this.activePassengerCount = criteria.adults;

        searchFlights({
            origin: criteria.origin,
            dest: criteria.destination,
            departureDate: criteria.departureDate,
            adults: criteria.adults,
            cabin: criteria.cabinClass
        })
        .then((resultList) => {
            this.discoveredOffersCatalog = resultList ? resultList : [];
            this.dispatchEvent(new ShowToastEvent({
                title: 'Search Completed',
                message: `Successfully retrieved ${this.discoveredOffersCatalog.length} live flight routes from Duffel.`,
                variant: 'success'
            }));
        })
        .catch((error) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Search Routing Failure',
                message: error?.body?.message || 'Unauthorized or malformed payload configuration.',
                variant: 'error',
                mode: 'sticky'
            }));
            this.discoveredOffersCatalog = [];
        })
        .finally(() => { this.isLoading = false; });
    }

    // STEP 2: Intercepts card selection and routes user forward into sub-form panels 
     handleFlightTicketSelection(event) {
        if (!event || !event.detail) return;
        
        // Captures the active 15-minute token ID passed up out of the result row card
        this.activeOfferId = event.detail.offerId;
        this.activeExpectedPrice = event.detail.price;
        
        // Immediately routes the travel agent forward into the passenger form canvas
        this.currentViewStage = 'checkout'; 
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Fare Locked Successfully',
            message: 'Active checkout token transferred. Please complete traveler data details within 15 minutes.',
            variant: 'info'
        }));
    }

    // STEP 3: Invokes the sub-component public API validation checker method 
    handleProcessCheckoutVerification() {
        const passengerFormElement = this.template.querySelector('c-passenger-details-form');
        
        if (passengerFormElement) {
            // Invoke the required public @api validation function 
            const isManifestValid = passengerFormElement.validateAllPassengers();
            
            if (!isManifestValid) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Form Validation Error',
                    message: 'Please complete all required passenger data fields before proceeding.',
                    variant: 'warning'
                }));
                return;
            }
            
            // Execute the imperative backend transactional creation query if valid 
            this.executeDatabaseCommit();
        }
    }

    // STEP 4: Commits records via standard transactional roll-back architectures
    executeDatabaseCommit() {
        this.isLoading = true;
        const targetPassengerId = this.recordId ? this.recordId : null;

        if (!targetPassengerId) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Missing Context Error',
                message: 'Please execute bookings directly from an active Contact detail page view layout.',
                variant: 'error'
            }));
            this.isLoading = false;
            return;
        }

        createBooking({
            contactId: targetPassengerId,
            offerJson: this.activeOfferId,
            seats: this.activePassengerCount,
            seatClass: 'economy'
        })
        .then((createdRecordMetadata) => {
            this.generatedPnrCode = createdRecordMetadata.Name; // Map auto-number string as PNR
            this.currentViewStage = 'success'; // Move to final success screen view panel [Criteria 18]
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Airline Booking Success',
                message: `Ticket successfully issued! Confirmed PNR Reference Code: ${this.generatedPnrCode}`,
                variant: 'success'
            }));
        })
        .catch((error) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Reservation Refused',
                message: error?.body?.message || 'Database transactional commit rolled back.',
                variant: 'error',
                mode: 'sticky'
            }));
        })
        .finally(() => { this.isLoading = false; });
    }

    handleReturnToSearchStage() {
        this.discoveredOffersCatalog = [];
        this.currentViewStage = 'search';
    }
}
