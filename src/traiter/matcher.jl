struct Backtrack
    token_idx::Int64
    pred_idx::Int64
    phrase_idx::Int64
    repeat_idx::Int64
end


struct Match
    rule::Rule
    first_token::Int64
    last_token::Int64
    predicates::Array{Predicate}
end


function match()
    # while token_idx < tokens.size():
    #
    # for rule_idx in range(self.rules.size()):
    #     rule = self.rules[rule_idx]
    #
    #     pred_token, pred_idx, pred_state = token_idx, 0, 0
    #     token2pred.empty()
    #
    #     while pred_idx < rule.predicates.size():
    #         pred = rule.predicates[pred_idx]
    #
    #         success, length, phrase_idx, repeat_idx = pred.func(
    #             rule, tokens[token_idx])
    #
    #         if success:
    #             # A candidate match
    #             self.stack.push(Backtrack(
    #                 token_idx, rule_idx, phrase_idx, repeat_idx))
    #
    #             for i in range(length):
    #                 token2pred.push_back(pred_idx)
    #
    #             rule_idx += 1
    #             pred_token += length
    #
    #         elif not self.stack.empty():
    #             # The match failed so try backtracking
    #             backtrack = self.stack.pop()
    #             for i in range(token_idx, backtrack.token_idx, -1):
    #                 token2pred.pop_back()
    #             pred_idx = backtrack.pred_idx
    #             repeat_idx = backtrack.repeat_idx
    #             phrase_idx = backtrack.phrase_idx
    #             rule_token = backtrack.token_idx
    #
    #         else:
    #             # All matches & backtracks failed so try next pattern
    #             break
    #
    #     else:
    #         # All rules in pattern passed so it's a match
    #         matches.append(
    #             Match(rule_idx, token_idx, pred_token, token2pred))
    #         token_idx = pred_token - 1  # Handle += 1 below
    #         self.stack.clear()
    #         break  # Skip other patterns
    #
    # token_idx += 1  # Try next token
    #
    # matches

end
