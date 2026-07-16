import { LightningElement, track } from 'lwc';
import { LightningAlert } from 'lightning/alert';

export default class FlightSearchForm extends LightningElement {
    // Reactive tracking property parameters definitions [Doc: 13.1]
    @track origin = '';
    @track destination = '';
    @track departureDate = '';
    @track cabinClass = 'economy';
    @track adults = 1;
    @track isLoading = false;

    // Component static select option collections configuration mappings
    cabinOptions = [
        { label: 'Economy Coach', value: 'economy' },
        { label: 'Business Executive', value: 'business' },
        { label: 'First Class VIP', value: 'first' }
    ];

    // Synchronizes dynamic state updates across keyboard capture actions
    handleOriginChange(event) { this.origin = event.detail.value.toUpperCase(); }
    handleDestinationChange(event) { this.destination = event.detail.value.toUpperCase(); }
    handleDepartureChange(event) { this.departureDate = event.detail.value; }
    handleCabinChange(event) { this.cabinClass = event.detail.value; }
    handleAdultsChange(event) { this.adults = parseInt(event.detail.value, 10); }

    // Evaluates constraints criteria bounds and dispatches bubbles event [Doc: 13.1]
    async handleSearchExecute() {
        const allInputsValid = [...this.template.querySelectorAll('.validate-field')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (!allInputsValid) return;

        if (this.origin === this.destination) {
            await LightningAlert.open({ message: 'Origin and Destination parameters cannot match.', theme: 'error', label: 'Invalid Route Configuration' });
            return;
        }

        this.isLoading = true;

        // Package structural parameter models matching your search backend signature
        const searchCriteriaPayload = {
            origin: this.origin,
            destination: this.destination,
            departureDate: this.departureDate,
            adults: this.adults,
            cabinClass: this.cabinClass
        };

        // Dispatches the data upward via custom execution bubbles hooks [Doc: 13.1]
        const criteriaSearchEvent = new CustomEvent('flightsearch', {
            detail: searchCriteriaPayload
        });
        
        this.dispatchEvent(criteriaSearchEvent);
        this.isLoading = false;
    }
}
