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
    token2pred::Vector{Predicate}
    # Match() = new(Nothing, 0, 0, [])
end

function in_phrases(
    tokens::Tokens,
    pred::Predicate,
    token_idx::INT,
    phrase_idx::INT,
    repeat_idx::INT,
)::Bool

end


function match(rules::Rules, tokens::Tokens)::Vector{Match}
    stack::Stack{Backtrack} = Stack()
    matches::Vector{Match} = []
    token_idx = 1

    while token_idx <= length(tokens)

        for rule_idx = 1:length(rules)
            rule = self.rules[rule_idx]

            mathched = true
            pred_token = token_idx      # Start with the current token
            token2pred = []             # Link predicates to matching tokens
            phrase_idx, repeat_idx = 0, 0

            while pred_idx <= length(rule)
                pred = rule[pred_idx]

                success = pred.func(
                    tokens,
                    pred,
                    token_idx,
                    phrase_idx,
                    repeat_idx,
                )

                # A candidate match
                if success
                    self.stack.push(Backtrack(
                        pred_token,
                        pred_idx,
                        phrase_idx,
                        repeat_idx,
                    ))
                    for i = 1:length
                        token2pred.push_back(pred_idx)
                    end
                    rule_idx += 1
                    pred_token += length

                # The match failed so try backtracking
                elseif !isempty(stack)
                    backtrack = stack.pop()
                    for i = token_idx:backtrack.token_idx
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


const PREDICATES = Dict("in_phrases" => in_phrases,)
