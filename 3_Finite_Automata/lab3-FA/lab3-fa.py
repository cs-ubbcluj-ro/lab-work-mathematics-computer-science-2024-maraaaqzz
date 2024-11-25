import json

def read_fa_from_file(file_name):
    try:
        with open(file_name, 'r') as file:
            fa = json.load(file)
            return fa
    except Exception as e:
        print(f"Error reading file: {e}")
        return None


def display_fa(fa):
    print("Finite Automaton:")
    print(f"Set of states: {fa['states']}")
    print(f"Alphabet: {fa['alphabet']}")
    print(f"Transition functions:")

    for state, transitions in fa['transitions'].items():
        for symbol, target in transitions.items():
            print(f"  T({state}, {symbol}) -> {target}") 

    print(f"Initial State: {fa['initial_state']}")
    print(f"Set of Final States: {fa['final_states']}")



# bonus : verify if the given string is a valid lexical token
def is_valid(fa, input_string):
    current_state = fa['initial_state']

    for symbol in input_string:
        if symbol not in fa['alphabet']:
            return False

        # q0 + a -> q1, so current_state = q1.
        current_state = fa['transitions'].get(current_state, {}).get(symbol)

        if current_state is None:
            return False

    return current_state in fa['final_states']


def main():
    file_name = "FA.in"
    fa = read_fa_from_file(file_name)
    
    if not fa:
        print("Failed to load the finite automaton.")
        return
    
    display_fa(fa)
    
    # Bonus 
    input_string = input("verify string: ").strip()
    
    if is_valid(fa, input_string):
        print(f"The string '{input_string}' is a valid lexical token.")
    else:
        print(f"The string '{input_string}' is NOT a valid lexical token.")


if __name__ == "__main__":
    main()
