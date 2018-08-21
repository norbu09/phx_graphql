import React, { Component } from 'react';
import gql from "graphql-tag";
import { Mutation } from "react-apollo";

const UPD_PASSWORD = gql`
  mutation UpdPass($currentPassword: String!, $newPassword: String!) {
    updatePassword(currentPassword: $currentPassword, newPassword: $newPassword){
      username
    }
  }
`;

class PasswordUpdate extends Component {
  render() {
    let old_pw;
    let new_pw;

    return (<Mutation mutation={UPD_PASSWORD} variables={{ new_pw, old_pw }}>
      {(updatePassword, { loading, error, data }) => (
        <form
          onSubmit={e => {
            e.preventDefault();
            updatePassword({ variables: { newPassword: new_pw.value, currentPassword: old_pw.value} });
            old_pw.value = "";
            new_pw.value = "";
          }}
        >
          <fieldset id="update_password" className="ba b--transparent ph0 mh0">
            <div className="mt3">
              <label className="db fw6 lh-copy f6" htmlFor="current_password">
                Current password <input className="pa2 input-reset ba hover-bg-blue hover-light-gray w-100" type="password" name="old_pw"  id="old_pw" ref={node => {old_pw = node;}} />
              </label>
            </div>
            <div className="mt3">
              <label className="db fw6 lh-copy f6" htmlFor="new_password">
                New password <input className="pa2 input-reset ba hover-bg-blue hover-light-gray w-100" type="password" name="new_pw"  id="new_pw" ref={node => {new_pw = node;}} />
              </label>
            </div>
          </fieldset>
          <div className="">
            <input className="b ph3 pv2 input-reset ba b--black bg-transparent pointer f6 dib hover-bg-blue hover-light-gray" type="submit" value={loading ? "loading" : "update"} />
          </div>
      </form>
      )}
    </Mutation>);
  }
}

export default PasswordUpdate;
