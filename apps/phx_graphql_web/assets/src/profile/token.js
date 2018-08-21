import React from 'react';
import Moment from 'react-moment';
import gql from "graphql-tag";
import { Mutation } from "react-apollo";
import Query from '../query.js'


const updateCache = (cache, data) => {
  let thing = Object.keys(data.data)[0]
  cache.writeQuery({
    query: GET_TOKEN,
    data: {
      allToken: data.data[thing]
    }
  })
}

const GET_TOKEN = gql`
  query Token {
    allToken{
      token
      created
    }
  }
`;

const DELETE_TOKEN = gql`
  mutation DelToken($token: ID!) {
    deleteToken(token: $token){
      token
      created
    }
  }
`;

const CREATE_TOKEN = gql`
  mutation AddToken {
    createToken{
      token
      created
    }
  }
`;


export default () => (
  <ul className="list pl0 mt0 measure">
    <Query query={GET_TOKEN}>
      {({ allToken }) => {
        return allToken.map(({ token, created }) => (
          <li key={token} className="flex items-center lh-copy pa3 ph0-l bb b--black-10">
            <div className="pl3 flex-auto">
              <span className="f6 db black-70">{token}<br />created <Moment toNow unix ago>{created}</Moment> ago</span>
            </div>
            <Mutation
              mutation={DELETE_TOKEN}
              variables={{ token }}
              update={updateCache}
            >
              {(deleteToken, { loading, error }) => (
                <span
                  onClick={() => deleteToken({ variables: { token } })}
                  className="b ph3 pv2 input-reset ba b--red bg-transparent pointer f6 dib hover-bg-red"
                >
                  {loading ? 'deleting' : 'x'}
                </span>
              )}
            </Mutation>
          </li>
        ))
      }}
    </Query>
    <li key="new" className="flex items-center lh-copy pa3 ph0-l bb b--black-10">
      <Mutation 
        mutation={CREATE_TOKEN} 
        update={updateCache}
      >
        {(createToken, { loading, error }) => (
          <span
            onClick={() => createToken()}
            className="b ph3 pv2 input-reset ba b--black bg-transparent pointer f6 dib hover-bg-green"
          >
            {loading ? 'adding' : 'add'}
          </span>
        )}
      </Mutation>
    </li>
  </ul>
)
