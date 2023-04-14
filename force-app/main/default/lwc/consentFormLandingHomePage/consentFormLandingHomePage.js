import { LightningElement, wire } from 'lwc';
import BAYER_LOGO from '@salesforce/resourceUrl/bayer_logo';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailToHCP from '@salesforce/apex/OneTrustService.sendEmailToHCP';
import sendConsent from '@salesforce/apex/OneTrustService.sendConsent';
import decryptEmail from '@salesforce/apex/OneTrustService.decryptEmail';
import heading_ConsentForm from '@salesforce/label/c.Heading_ConsentForm';
import text1_ConsentForm from '@salesforce/label/c.Text1_ConsentForm';
import text2_ConsentForm from '@salesforce/label/c.Text2_ConsentForm';
import link1_ConsentForm from '@salesforce/label/c.Link1_ConsentForm';
import link2_ConsentForm from '@salesforce/label/c.Link2_ConsentForm';
import link1Text_ConsentForm from '@salesforce/label/c.Link1Text_ConsentForm';
import link2Text_ConsentForm from '@salesforce/label/c.Link2Text_ConsentForm';
import consentGivenSuccessMsg_ConsentForm from '@salesforce/label/c.ConsentGivenSuccessMsg_ConsentForm';
import consentOnlyForPrivacySuccessMsg_ConsentForm from '@salesforce/label/c.ConsentOnlyForPrivacySuccessMsg_ConsentForm';
import consentOnlyForMultichannelMarketing_ConsentForm from '@salesforce/label/c.ConsentOnlyForMultichannelMarketing_ConsentForm';
import checkbox1_ConsentForm from '@salesforce/label/c.Checkbox1_ConsentForm';
import checkbox2_ConsentForm from '@salesforce/label/c.Checkbox2_ConsentForm';
import checkbox2SubText_ConsentForm from '@salesforce/label/c.Checkbox2SubText_ConsentForm';
import send_ConsentForm from '@salesforce/label/c.Send_ConsentForm';
import apiCallFailMsg_ConsentForm from '@salesforce/label/c.APICallFailMsg_ConsentForm';
import msgWhenNoCheckboxSelected_ConsentForm from '@salesforce/label/c.MsgWhenNoCheckboxSelected_ConsentForm';
import emailBody_ConsentForm from '@salesforce/label/c.EmailBody_ConsentForm';
import emailSubject_ConsentForm from '@salesforce/label/c.EmailSubject_ConsentForm';
import decryptionAlgorithm_ConsentForm from '@salesforce/label/c.DecryptionAlgorithm_ConsentForm';
import AESKey_ConsentForm from '@salesforce/label/c.AESKey_ConsentForm';
import initializationVector_ConsentForm from '@salesforce/label/c.InitializationVector_ConsentForm';

export default class ConsentFormLandingHomePage extends LightningElement {

    integrationFailureMsg_ConsentForm = "";
    value = [];
    logo = BAYER_LOGO;
    checkboxOne = false;
    checkboxTwo = false;
    isDisplayHomePage = true;
    isAPICallSuccess = true;
    consentStatus = "NOT_GIVEN";
    currentPageReference = null; 
    urlStateParameters = null;
    urlEmail = "";
    apiResponse;
    hideSubmit = true;
    consentAPICallFailureDueToSubmission = false;
    encryptedUrlEmail;

    label = {
        heading_ConsentForm,
        text1_ConsentForm,
        text2_ConsentForm,
        link1_ConsentForm,
        link2_ConsentForm,
        link1Text_ConsentForm,
        link2Text_ConsentForm,
        consentGivenSuccessMsg_ConsentForm,
        consentOnlyForPrivacySuccessMsg_ConsentForm,
        consentOnlyForMultichannelMarketing_ConsentForm,
        checkbox1_ConsentForm,
        checkbox2_ConsentForm,
        checkbox2SubText_ConsentForm,
        send_ConsentForm,
        apiCallFailMsg_ConsentForm,
        msgWhenNoCheckboxSelected_ConsentForm,
        emailBody_ConsentForm,
        emailSubject_ConsentForm,
        decryptionAlgorithm_ConsentForm,
        AESKey_ConsentForm,
        initializationVector_ConsentForm
    };

    

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }

    setParametersBasedOnUrl() {
        this.encryptedUrlEmail = this.urlStateParameters.email;
        
        decryptEmail({
            algorithmName:decryptionAlgorithm_ConsentForm, 
            privateKey:AESKey_ConsentForm, 
            initializationVector:initializationVector_ConsentForm, 
            encrypted : this.encryptedUrlEmail
        })
            .then((result)=>{
                this.urlEmail = result;
            })
                
            .catch((error) => {
                console.log(error);
            }); 


    }

    consentStatusUpdateOnSubmit(){
        
        if(this.checkboxOne && this.checkboxTwo){
            this.consentStatus= "ACTIVE";
        }
        else{
            this.consentStatus= "NOT_GIVEN";
        }
    }

    

    handleClick(event){
        
        if(!this.checkboxOne && !this.checkboxTwo){
           this.isDisplayHomePage = false;
           this.consentAPICallFailureDueToSubmission = true;
           
            //alert("Herhangi bir tercih yapmadınız.");
        }
                
        else{
            this.consentStatusUpdateOnSubmit();
            if(this.checkboxOne== true){

                sendEmailToHCP({
                body: emailBody_ConsentForm,
                toSend: this.urlEmail, 
                subject: emailSubject_ConsentForm
                })
                .then((result)=>{
                console.log("Email sent Successfully.");
                })
                .catch((error) => {
                console.log(error);
                }); 
            }

            sendConsent({
                email: this.urlEmail, 
                isMultiChannelMarketing: this.checkboxOne,
                isDpProcessing: this.checkboxTwo, 
                isThirdCountryTransfers: this.checkboxTwo
            })
            .then((result)=>{
                
                this.isDisplayHomePage= false;
                this.apiResponse = result;
                if(this.apiResponse=='SUCCESS'){
                    this.isAPICallSuccess= true;

                }
                else{
                    this.isAPICallSuccess= false;
                }
            })
            .catch((error) => {
                console.log(error);
                this.isDisplayHomePage= false;
                this.isAPICallSuccess= false;
                
            });

        }
        
        
    }

    handleFirstCheckboxChange(event){
        if(event.target.checked){
            this.checkboxOne= true;
            this.hideSubmit= false;
        }
        else{
            this.checkboxOne= false;
        }
    }

    handleSecondCheckboxChange(event){
        if(event.target.checked){
            this.checkboxTwo= true;
        }
        else{
            this.checkboxTwo= false;
        }
        
    }

    

    get consentGivenSucess(){
        return (this.checkboxOne && this.checkboxTwo && this.isAPICallSuccess);
    }

    get consentOnlyMultichannelMarketingSucess(){
        return (this.checkboxOne && !(this.checkboxTwo) && this.isAPICallSuccess);
    }

    get consentOnlyForPrivacySucess(){
        return (!(this.checkboxOne) && this.checkboxTwo && this.isAPICallSuccess);
        
    }

    get consentAPICallFailure(){
        return (!(this.isAPICallSuccess));
    }
    

}