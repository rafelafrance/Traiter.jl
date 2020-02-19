struct Backtrack
    token_idx::INT
    pred_idx::INT
    phrase_idx::INT
    repeat_idx::INT
end


struct Match
    rule::Rule
    first_token::INT
    last_token::INT
    token2pred::Predicates
    # Match() = new(Nothing, 0, 0, [])
end


const Matches = Vector{Match}


function match(rules::Rules, tokens::Tokens)::Matches
    stack::Stack{Backtrack} = Stack()
    matches::Matches = []
    token_idx = 1

    while token_idx <= length(tokens)

        for rule_idx = 1:length(rules)
            rule = self.rules[rule_idx]

            mathched = true
            pred_token = token_idx      # Start with the current token
            token2pred = []             # Link predicates to matching tokens
            phrase_idx, repeat_idx = 0, 0

            while pred_idx <= length(rule.predicates)
                pred = rule.predicates[pred_idx]

                result = pred.func(tokens, token_idx, phrase_idx, repeat_idx)

                # A candidate match
                if result.success == true
                    self.stack.push(Backtrack(
                        token_idx, rule_idx, phrase_idx, repeat_idx))
                    for i in 1:length
                        token2pred.push_back(pred_idx)
                    end
                    rule_idx += 1
                    pred_token += length

                # The match failed so try backtracking
                elseif !isempty(stack)
                    backtrack = stack.pop()
                    for i in token_idx:backtrack.token_idx
                        token2pred.pop_back()
                    end
                    pred_idx = backtrack.pred_idx
                    repeat_idx = backtrack.repeat_idx
                    phrase_idx = backtrack.phrase_idx
                    rule_token = backtrack.token_idx

                # All matches & backtracks failed so try next pattern
                else
                    matched = false
                    break
                end
            end

            # All predicates in pattern passed so it's a match
            if matched
                # matches.append(
                #     Match(rule_idx, token_idx, pred_token, token2pred))
                # token_idx = pred_token - 1  # Handle += 1 below
                # self.stack.clear()
                # break  # Skip other patterns
            end
        end

        token_idx += 1
    end

    matches

end
