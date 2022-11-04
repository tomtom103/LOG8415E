# MapReduce
## How the map function works

We divide the text file line into two parts in the map function: the user id for whom we want to make friend recommendations and the list of his current friends. We send the user's id, along with his friend list and the indicator "/DEG1." We also verify the scenario when the user has no friends. Following that, we emit all of the potential mutual friends from the list, including the indicator "/DEG2" since they share a friend in common. The map function essentially maps the user relationships and adds an indicator to help the reduce function.

## How the reduce function works

We group all of the recommended friends by users in the reduce function. We take the value from the key-value emitted by the map function and split it in two, the values before the "/" and the indicator after the "/." If we see the indicator "CURRENT," we add them to the list of current friends so we can remove them from the list of recommendations later, and if we see the indicator "/DEG2," we add them to the list of recommendations. Finally, we emit a key-value pair in which the value is from a list of recommendations sorted in decreasing order in order to obtain the top ten recommendations.