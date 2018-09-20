import React, {Component} from 'react'
import gql from "graphql-tag"
import { Query } from "react-apollo";
import Messages from "./messages";

const ACTIVITY_SUBSCRIPTION = gql`
  subscription onUserActivity($id: ID!) {
	userActivity(user_id: $id) {
	  message
	}
}
`;

const GET_USER_ACTIVITY = gql`
  {
	userActivity {
		message
		}
	  }
`;

export const ActivityQuery = ({ children }) => (
  <ul className="list pl0 mt0 measure">
	<Query query={GET_USER_ACTIVITY}>
	  {({ loading, error, data, subscribeToMore }) => {
		if (loading)
		  return ( "Loading ..." );
		if (error) return <p>Error *sad face*</p>;
		const subscribeToMoreMessages = ({id}) => {
		  subscribeToMore({
			document: ACTIVITY_SUBSCRIPTION,
			variables: {id },
			updateQuery: (prev, { subscriptionData }) => {
			  if (!subscriptionData.data || !subscriptionData.data.userActivity)
				return prev;
			  const newMsgs = subscriptionData.data.userActivity;
			  return Object.assign({}, prev, {
				userActivity: [...prev.userActivity, newMsgs]
			  });
			}
		  });
		};
		return children(data.userActivity, subscribeToMoreMessages);
	  }}
	</Query>
</ul>);

export default class ActivityFeed extends Component {
  render(){
	return (<ActivityQuery>
	  {(messages, subscribeToMoreMessages) => (
		<Messages messages={messages} subscribeToMoreMessages={subscribeToMoreMessages}  />
	  )}
	</ActivityQuery>);
  }
}
