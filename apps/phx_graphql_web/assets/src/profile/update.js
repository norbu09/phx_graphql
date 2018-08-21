import React, { Component } from 'react';
import gql from "graphql-tag";
import { Query, Mutation } from "react-apollo";

const UPD_PROFILE = gql`
  mutation UpdProfile($id: ID!, $version: String!, $username: String, $company: String) {
    updateProfile(profile: {id: $id, version: $version, username: $username, company: $company}) {
      id
      version
      username
      company
    }
  }
`;

const GET_PROFILE = gql`
  {
    getProfile {
      id
      version
      username
      company
    }
  }
`;

const updateCache = (cache, { data: { updateProfile } }) => {
  cache.writeQuery({
    query: GET_PROFILE,
    data: {
      getProfile: updateProfile
    }
  })
}

class ProfileUpdate extends Component {
  render() {
    let id;
    let version;
    let username;
    let company;


    return (<Mutation mutation={UPD_PROFILE} update={updateCache} variables={{ id, version, username, company }}>
      {(updateProfile, { loading, error, data }) => (
        <form
          onSubmit={e => {
            e.preventDefault();
            updateProfile({ variables: { id: id.value, version: version.value, username: username.value , company: company.value} });
          }}
        >
          <Query query={GET_PROFILE}>
            {({ loading, error, data }) => {
              if (loading) return <p>Loading...</p>;
              if (error) return <p>Error :(</p>;

              return (
                <fieldset id="profile" className="ba b--transparent ph0 mh0">
                  <div className="mt3">
                    <label className="db fw6 lh-copy f6" htmlFor="username">
                      Email <input className="pa2 input-reset ba hover-bg-blue hover-light-gray w-100" type="email" name="username"  id="username" defaultValue={data.getProfile.username} ref={node => {username = node;}} />
                    </label>
                  </div>
                  <div className="mv3">
                    <label className="db fw6 lh-copy f6" htmlFor="company">
                      Company <input className="pa2 input-reset ba hover-bg-blue hover-light-gray w-100" type="text" name="company"  id="company" defaultValue={data.getProfile.company} ref={node => {company = node;}}/>
                    </label>
                  </div>
                  <input type="hidden" name="id" value={data.getProfile.id} ref={node => {id = node;}} />
                  <input type="hidden" name="version" value={data.getProfile.version} ref={node => {version = node;}} />
                </fieldset>
              );
            }}
          </Query>
          <div className="">
            <input className="b ph3 pv2 input-reset ba b--black bg-transparent pointer f6 dib hover-bg-blue hover-light-gray" type="submit" value={loading ? "loading" : "update"} />
          </div>
        </form> 
      )}
    </Mutation>);
  }
}

export default ProfileUpdate;
