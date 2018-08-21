import React, { Component } from 'react';
import ProfileUpdate from "./profile/update"
import PasswordUpdate from "./profile/password"
import Token from "./profile/token"

class Profile extends Component {
  render() {

    return (
      <div className="flex flex-wrap">
        <article className="fl w-50 pa4 black-80">
          <h2 className="f4 measure">update profile</h2>
          <ProfileUpdate />
        </article>
        <article className="fl w-50 pa4 black-80">
          <h2 className="f4 measure">change password</h2>
          <PasswordUpdate />
        </article>
        <article className="fl w-50 pa4 black-80">
          <h2 className="f4 measure">API token</h2>
          <Token />
        </article>
      </div>
    );
  }
}

export default Profile;
