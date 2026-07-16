import { LightningElement, api, track } from 'lwc';

export default class PassengerDetailsForm extends LightningElement {
    @track passengerFormsList = [];
    
    // Generates N sub-form arrays reactively matching the frontend request criteria
    @api 
    set passengerCount(value) {
        let forms = [];
        const count = parseInt(value, 10) || 1;
        for (let i = 0; i < count; i++) {
            forms.push({ id: 'pass-' + i, displayIndex: i + 1 });
        }
        this.passengerFormsList = forms;
    }
    get passengerCount() { return this.passengerFormsList.length; }

    // Required Public API Verification Hook checking input criteria
    @api 
    validateAllPassengers() {
        return [...this.template.querySelectorAll('.passenger-input')]
            .reduce((validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }, true);
    }
}
