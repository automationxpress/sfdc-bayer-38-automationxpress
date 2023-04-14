import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchUsers from '@salesforce/apex/AzureActiveDirectoryService.searchUsers';
import Name from '@salesforce/label/c.Name';
import NoResults from '@salesforce/label/c.NoResults';

export default class UserEntrySearch extends LightningElement {
    displayNameSearch;
    isSearchResultVisible = false;
    isNoResultsVisible = false;
    userSearchResult;
    error;
    label = {
        Name,
        NoResults
    };

    handleChange(event) {
        this.displayNameSearch = event.target.value;
        if(this.displayNameSearch.length > 2) {
            this.handleSearch();
        } else {
            this.hideSearchResult();
            this.hideNoResults();
        }
    }

    handleSearch(){
        searchUsers({displayName : this.displayNameSearch })
        .then(result => {
            this.userSearchResult = result;
            this.showSearchResult();
            if(this.userSearchResult.length > 0){
                this.hideNoResults();
            } else {
                this.showNoResults();
            }
        }).catch(error => {
            this.showError(error.body.message);
        });
    }

    handleSelect(event){
        this.hideSearchResult();
        var selectedUser = event.currentTarget.dataset;
        this.displayNameSearch = selectedUser.displayName;
        var userDetails = {
            firstName: selectedUser.givenName, 
            lastName: selectedUser.surname, 
            email: selectedUser.mail,
            cwid: selectedUser.onPremisesSamAccountName,
            userPrincipalName: selectedUser.userPrincipalName
        };
        const selectedEvent = new CustomEvent('valueselected', {
            detail: userDetails
        });
        this.dispatchEvent(selectedEvent);
    }

    showSearchResult(){
        this.isSearchResultVisible = true;
    }

    hideSearchResult(){
        this.isSearchResultVisible = false;
    }

    showNoResults(){
        this.isNoResultsVisible = true;
    }

    hideNoResults(){
        this.isNoResultsVisible = false;
    }

    showError(message) {
        const evt = new ShowToastEvent({
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}