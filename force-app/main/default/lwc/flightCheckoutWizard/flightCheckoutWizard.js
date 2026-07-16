import { LightningElement, track, api } from 'lwc';
import createBooking from '@salesforce/apex/BookingService.createBooking';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FlightCheckoutWizard extends LightningElement {
    @api recordId; // Automatic contact record configuration binding ID reference profile
    @api offerId = 'off_test99'; // Default testing mock key mapping
    @api expectedPrice = 450.00;

    @track currentStep = '1';
    @track pnrCode = '';
    @track passenger = { firstName: '', lastName: '', dob: '', passport: '', mealPref: 'Standard' };

    mealOptions = [
        { label: 'Standard Flight Meal', value: 'Standard' },
        { label: 'Vegetarian Meal Option', value: 'Vegetarian' },
        { label: 'Kosher Catering Option', value: 'Kosher' }
    ];

    get isStepOne() { return this.currentStep === '1'; }
    get isStepTwo() { return this.currentStep === '2'; }
    get isStepThree() { return this.currentStep === '3'; }

    handleFirstChange(e) { this.passenger.firstName = e.detail.value; }
    handleLastChange(e) { this.passenger.lastName = e.detail.value; }
    handleDobChange(e) { this.passenger.dob = e.detail.value; }
    handlePassportChange(e) { this.passenger.passport = e.detail.value; }
    handleMealChange(e) { this.passenger.mealPref = e.detail.value; }

    goToStepTwo() { this.currentStep = '2'; }
    goToStepOne() { this.currentStep = '1'; }

    executeFinalBooking() {
        createBooking({
            contactId: this.recordId,
            offerId: this.offerId,
            expectedPrice: this.expectedPrice
        })
        .then((result) => {
            this.pnrCode = result.Name; // Map standard auto-number name string as PNR
            this.currentStep = '3';
        })
        .catch((error) => {
            this.dispatchEvent(new ShowToastEvent({ title: 'Checkout Failed', message: error.body.message, variant: 'error' }));
        });
    }
}
