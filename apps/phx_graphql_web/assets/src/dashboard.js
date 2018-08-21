import React, { Component } from 'react';


class Dashboard extends Component {
  render() {
    let state = window.__INITIAL_STATE__;
    let welcome = "Welcome " + state.user.username;

    return (
      <div className="App">
        <h1 className="f2 lh-title fw9 mb3 mt0 pt3 bt bw2">{welcome}</h1>
      </div>
    );
  }
}

export default Dashboard;

