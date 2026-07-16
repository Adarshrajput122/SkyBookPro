public class CalculatorWizardController {
    // Properties to hold user inputs and result
    public Decimal num1 { get; set; }
    public Decimal num2 { get; set; }
    public String selectedOp { get; set; }
    public Decimal result { get; set; }
    
    // Variables to control step visibility
    public Boolean showStep1 { get; set; }
    public Boolean showStep2 { get; set; }
    public Boolean showStep3 { get; set; }
    
    // Constructor initializes the first step
    public CalculatorWizardController() {
        goToStep1();
    }
    
    // Navigation to Step 1
    public void goToStep1() {
        showStep1 = true;
        showStep2 = false;
        showStep3 = false;
    }
    
    // Navigation to Step 2
    public void goToStep2() {
        showStep1 = false;
        showStep2 = true;
        showStep3 = false;
    }
    
    // Navigation to Step 3 + performs calculation
    public void goToStep3() {
        calculateResult();
        showStep1 = false;
        showStep2 = false;
        showStep3 = true;
    }
    
    // Options for the dropdown menu
    public List<SelectOption> getOperationOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Add', 'Add'));
        options.add(new SelectOption('Sub', 'Sub'));
        options.add(new SelectOption('Mul', 'Mul'));
        options.add(new SelectOption('Div', 'Div'));
        return options;
    }
    
    // Core logic processing
    private void calculateResult() {
        if (num1 == null || num2 == null) {
            result = 0;
            return;
        }
        
        if (selectedOp == 'Add') {
            result = num1 + num2;
        } else if (selectedOp == 'Sub') {
            result = num1 - num2;
        } else if (selectedOp == 'Mul') {
            result = num1 * num2;
        } else if (selectedOp == 'Div') {
            if (num2 != 0) {
                result = num1 / num2;
            } else {
                result = 0; // Handle division by zero gracefully
            }
        }
    }
}