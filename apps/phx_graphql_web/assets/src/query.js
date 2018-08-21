import React from 'react'
import { Query } from 'react-apollo'

export default ({ children, query, ...rest }) => (
  <Query query={query} {...rest}>
    {({ error, loading, data }) => {
      if (error) return 'sorry, something broke'
      if (loading) return 'loading ...'

      return children(data)
    }}
  </Query>
)

