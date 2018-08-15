import React, { Component } from 'react';
import gql from "graphql-tag";
import { ApolloClient } from 'apollo-client';
import { createHttpLink } from 'apollo-link-http';
import { setContext } from 'apollo-link-context';
import { InMemoryCache } from 'apollo-cache-inmemory';

const httpLink = createHttpLink({
  uri: "http://localhost:4000/api"
});

const token = window.__INITIAL_STATE__.token;
const authLink = setContext((_, { headers }) => {
  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    }
  }
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache()
});

class App extends Component {
  render() {
    let state = window.__INITIAL_STATE__;
    let welcome = "Welcome " + state.user.username;

    client
      .query({
        query: gql`
      {
        allThings {
          description
        }
      }
    `
      })
      .then(result => console.log(result));



    return (
      <div className="App">
        <h1 className="f2 lh-title fw9 mb3 mt0 pt3 bt bw2">{welcome}</h1>
        <p className="f5 lh-copy measure mt0-ns">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
      </div>
    );
  }
}

export default App;
