import React, {Component} from 'react'

export default class Messages extends Component {
  componentDidMount() {
	const user = window.__INITIAL_STATE__.user.id;
	this.props.subscribeToMoreMessages({id: user});
  }
  render(){
	let messages = this.props.messages;
	console.log("messages:", messages);
	if (messages) {
	  return messages.map(({ message }, k) => (
		<li key={k} className="flex items-center lh-copy pa3 ph0-l bb b--black-10">
		  <div className="pl3 flex-auto">
			<span className="f6 db black-70">message:<br />{message}</span>
		</div>
	</li>
	  ));
	} else {
	  return "Loading ..."
	}
  }
}
