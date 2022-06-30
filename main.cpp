#include <cstdio>
#include <cstdint>
#include <cmath>
#include <cstring>
#include <cctype>
#include <ctime>

using f64 = double;
using u8 = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

#define _DEBUG

#ifdef _DEBUG
#define DEBUG 1
#else
#define DEBUG 0
#endif

////////////////////////////////////////////////////////////////////////////////

struct f64_stack;
using stack_applicable_function = void (*)(f64_stack&, u8);

struct op_def {
	char name[10]; // up to 9 chars + 0 (align 8 bytes)
	u8 priority; // operator priority
	u8 max_args; // max number of args, used only for functions
	stack_applicable_function function;

	bool is_function() const {
		return priority >= 128;
	}
};
static_assert(sizeof(op_def) == 16);

struct special_f64 {
	union {
		f64 as_f64;
		u64 as_u64;

		// user variable
		struct {
			char name[6];
			u16 header;
		};

		// operator/function/constant
		struct {
			const op_def* def;
			u8 args;
			u8 flags;
			u16 _pad2;
		};

		// bracket
		struct {
			u32 offset;
			u8 _args;
			u8 _pad3;
			u16 _pad4;
		};
	};

	bool is_variable() const {
		return header == (0x7FF8 | 1);
	}
	bool is_dynamic() const {
		return header == (0x7FF8 | 2);
	}
	bool is_bracket() const {
		return header == (0x7FF8 | 3);
	}

	static special_f64 variable(const char* name, u8 len) {
		special_f64 value;
		u8 i = 0; 
		do {
			value.name[i] = name[i];
			i += 1;
		}
		while (i < len);
		while (i < 6) {
			value.name[i++] = 0;
		}
		value.header = 0x7FF8 | 1;
		return value;
	}

	static special_f64 dynamic(const op_def& def, u8 args) {
		special_f64 value;
		value.def = &def;
		value.args = args;
		value.flags = 0;
		value.header = 0x7FF8 | 2;
		return value;
	}

	static special_f64 bracket(u32 i = 0) {
		special_f64 value;
		value.as_u64 = 0;
		value.offset = i;
		value.args = 0;
		value.header = 0x7FF8 | 3;
		return value;
	}

	special_f64() {}
	special_f64(f64 raw) : as_f64(raw) {}
	special_f64(u64 raw) : as_u64(raw) {}

	operator f64() const { return as_f64; }
	operator u64() const { return as_u64; }

	bool operator ==(const f64& other) const {
		return reinterpret_cast<const u64&>(other) == as_u64;
	}
};
static_assert(sizeof(special_f64) == sizeof(f64));

////////////////////////////////////////////////////////////////////////////////

struct f64_stack {
	f64 values[255];
	u8 index;
	u8 _pad[7]; // round up the struct for 2048

	f64_stack() {
		if (DEBUG) {
			for (u8 i = 0; i < 255; i++) {
				values[i] = 0;
			}
		}
		index = sizeof(values) / sizeof(values[0]);
	}
	f64_stack(const f64_stack& other) {
		set_from(other);
	}

	void set_from(const f64_stack& other) {
		for (u8 i = 0; i < 255; i++) {
			values[i] = other.values[i];
		}
		index = other.index;
	}

	bool is_empty() {
		return index == static_cast<u8>(-1);
	}

	void push(f64 value) {
		values[++index] = value;
	}
	f64 pop() {
		return values[index--];
	}
	f64 peek() const {
		return values[index];
	}
};
static_assert(sizeof(f64_stack) == 2048);

////////////////////////////////////////////////////////////////////////////////

u32 round_f64_to_u32_forget_sign(f64 a) {
	return lround(fabs(a));
}

void apply_nop(f64_stack& stack, u8 argsCount) {
	// Nothing
}

void apply_add(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] += b;
}
void apply_subtract(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] -= b;
}
void apply_multiply(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] *= b;
}
void apply_divide(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] /= b;
}
void apply_modulo(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] = fmod(stack.values[stack.index], b);
}
void apply_power(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] = pow(stack.values[stack.index], b);
}
void apply_factorial(f64_stack& stack, u8 argsCount) {
	f64 result = 1;
	u32 i = round_f64_to_u32_forget_sign(stack.values[stack.index]);
	while (i) {
		result *= i--;
	}
	stack.values[stack.index] = result;
}

void apply_neg(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = -stack.values[stack.index];
}

const op_def op_def_add         { "+", .priority = 1, .max_args = 2, .function = apply_add      };
const op_def op_def_subtract    { "-", .priority = 1, .max_args = 2, .function = apply_subtract };
const op_def op_def_multiply    { "*", .priority = 2, .max_args = 2, .function = apply_multiply };
const op_def op_def_divide      { "/", .priority = 2, .max_args = 2, .function = apply_divide   };
const op_def op_def_modulo      { "%", .priority = 3, .max_args = 2, .function = apply_modulo   };
const op_def op_def_power       { "^", .priority = 4, .max_args = 2, .function = apply_power    };
const op_def op_def_factorial   { "!", .priority = 5, .max_args = 1, .function = apply_factorial };

const op_def op_def_neg         { "-", .priority = 1, .max_args = 1, .function = apply_neg };

////////////////////////////////////////////////////////////////////////////////

void apply_abs(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = fabs(stack.values[stack.index]);
}
void apply_sign(f64_stack& stack, u8 argsCount) {
	f64& x = stack.values[stack.index];
	x = (x > 0) - (x < 0);
}
void apply_ceil(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = ceil(stack.values[stack.index]);
}
void apply_floor(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = floor(stack.values[stack.index]);
}
void apply_trunc(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = trunc(stack.values[stack.index]);
}
void apply_round(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = round(stack.values[stack.index]);
}

void apply_min(f64_stack& stack, u8 argsCount) {
	f64 min = INFINITY;
	for (u8 i = 0; i < argsCount; i++) {
		const f64& x = stack.values[stack.index - i];
		if (min > x) {
			min = x;
		}
	}
	stack.index -= argsCount - 1;
	stack.values[stack.index] = min;
}
void apply_max(f64_stack& stack, u8 argsCount) {
	f64 max = -INFINITY;
	for (u8 i = 0; i < argsCount; i++) {
		const f64& x = stack.values[stack.index - i];
		if (max < x) {
			max = x;
		}
	}
	stack.index -= argsCount - 1;
	stack.values[stack.index] = max;
}
void apply_sum(f64_stack& stack, u8 argsCount) {
	f64 sum = 0;
	for (u8 i = 0; i < argsCount; i++) {
		sum += stack.values[stack.index - i];
	}
	stack.index -= argsCount - 1;
	stack.values[stack.index] = sum;
}
void apply_product(f64_stack& stack, u8 argsCount) {
	f64 product = 1;
	for (u8 i = 0; i < argsCount; i++) {
		product *= stack.values[stack.index - i];
	}
	stack.index -= argsCount - 1;
	stack.values[stack.index] = product;
}
void apply_count(f64_stack& stack, u8 argsCount) {
	stack.index -= argsCount - 1;
	stack.values[stack.index] = argsCount;
}
void apply_avg(f64_stack& stack, u8 argsCount) {
	f64 sum = 0;
	for (u8 i = 0; i < argsCount; i++) {
		sum += stack.values[stack.index - i];
	}
	stack.index -= argsCount - 1;
	stack.values[stack.index] = sum / argsCount;
}

void apply_sqrt(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = sqrt(stack.values[stack.index]);
}
void apply_cbrt(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = cbrt(stack.values[stack.index]);
}

void apply_rad(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] *= 0.017453292519943295;
}
void apply_deg(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] *= 57.29577951308232;
}

void apply_sin(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = sin(stack.values[stack.index]);
}
void apply_cos(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = cos(stack.values[stack.index]);
}
void apply_tan(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = tan(stack.values[stack.index]);
}
void apply_asin(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = asin(stack.values[stack.index]);
}
void apply_acos(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = acos(stack.values[stack.index]);
}
void apply_atan(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = atan(stack.values[stack.index]);
}
void apply_atan2(f64_stack& stack, u8 argsCount) {
	const f64 b = stack.pop();
	stack.values[stack.index] = atan2(stack.values[stack.index], b);
}

void apply_exp(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = exp(stack.values[stack.index]);
}
void apply_ln(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = log(stack.values[stack.index]);
}
void apply_log(f64_stack& stack, u8 argsCount) {
	if (argsCount == 1) {
		apply_ln(stack, argsCount);
		return;
	}
	const f64 b = stack.pop();
	stack.values[stack.index] = log(stack.values[stack.index]) / log(b);
}
void apply_log10(f64_stack& stack, u8 argsCount) {
	stack.values[stack.index] = log10(stack.values[stack.index]);
}

void apply_pi       (f64_stack& stack, u8 argsCount) { stack.push(3.141592653589793238463); } // use https://stackoverflow.com/a/30647428/4880243
void apply_euler    (f64_stack& stack, u8 argsCount) { stack.push(2.71828182845904523536); }
void apply_golden   (f64_stack& stack, u8 argsCount) { stack.push(1.6180339887498948482046); }
void apply_inf      (f64_stack& stack, u8 argsCount) { stack.push(INFINITY); }
void apply_nan      (f64_stack& stack, u8 argsCount) { stack.push(0.0 / 0.0); }
void apply_unixtime (f64_stack& stack, u8 argsCount) { stack.push(time(nullptr)); }
void apply_easteregg(f64_stack& stack, u8 argsCount) { stack.push(117813); }

u32 fib(u32 n) {
	if (n <= 1) return n;
	if (n <= 4) return n - 1;
	u32 d = 2;
	u32 a = 3;
	n -= 4;
	do {
		u32 b = d;
		d = a;
		a += b;
	}
	while (--n);
	return a;
}

void apply_fib(f64_stack& stack, u8 argsCount) {
	f64& a = stack.values[stack.index];
	u32 n = round_f64_to_u32_forget_sign(a);
	a = (a < 0 ? -1 : 1) * fib(n);
}

const op_def dynamic_defs[] = {
	{ "abs",        .priority = 128, .max_args = 1, .function = apply_abs },
	{ "sign",       .priority = 128, .max_args = 1, .function = apply_sign },
	{ "ceil",       .priority = 128, .max_args = 1, .function = apply_ceil },
	{ "floor",      .priority = 128, .max_args = 1, .function = apply_floor },
	{ "trunc",      .priority = 128, .max_args = 1, .function = apply_trunc },
	{ "round",      .priority = 128, .max_args = 1, .function = apply_round },

	{ "min",        .priority = 128, .max_args = 255, .function = apply_min },
	{ "max",        .priority = 128, .max_args = 255, .function = apply_max },
	{ "sum",        .priority = 128, .max_args = 255, .function = apply_sum },
	{ "product",    .priority = 128, .max_args = 255, .function = apply_product },
	{ "count",      .priority = 128, .max_args = 255, .function = apply_count },
	{ "avg",        .priority = 128, .max_args = 255, .function = apply_avg },

	{ "sqrt",       .priority = 128, .max_args = 1, .function = apply_sqrt },
	{ "cbrt",       .priority = 128, .max_args = 1, .function = apply_cbrt },

	{ "rad",       .priority = 128, .max_args = 1, .function = apply_rad },
	{ "deg",       .priority = 128, .max_args = 1, .function = apply_deg },

	{ "sin",        .priority = 128, .max_args = 1, .function = apply_sin },
	{ "cos",        .priority = 128, .max_args = 1, .function = apply_cos },
	{ "tan",        .priority = 128, .max_args = 1, .function = apply_tan },
	{ "asin",       .priority = 128, .max_args = 1, .function = apply_asin },
	{ "acos",       .priority = 128, .max_args = 1, .function = apply_acos },
	{ "atan",       .priority = 128, .max_args = 1, .function = apply_atan },
	{ "atan2",      .priority = 128, .max_args = 2, .function = apply_atan2 },

	{ "exp",        .priority = 128, .max_args = 1, .function = apply_exp },
	{ "ln",         .priority = 128, .max_args = 1, .function = apply_ln },
	{ "log",        .priority = 128, .max_args = 2, .function = apply_log },
	{ "log10",      .priority = 128, .max_args = 1, .function = apply_log10 },
	{ "fib",        .priority = 128, .max_args = 1, .function = apply_fib },

	{ "pi",         .priority = 128, .max_args = 0, .function = apply_pi },
	{ "euler",      .priority = 128, .max_args = 0, .function = apply_euler },
	{ "golden",     .priority = 128, .max_args = 0, .function = apply_golden },

	{ "inf",        .priority = 128, .max_args = 0, .function = apply_inf },
	{ "nan",        .priority = 128, .max_args = 0, .function = apply_nan },

	{ "unixtime",   .priority = 128, .max_args = 0, .function = apply_unixtime },
	{ "nr_albumu",  .priority = 128, .max_args = 0, .function = apply_easteregg },
};
constexpr unsigned int dynamic_defs_count = sizeof(dynamic_defs) / sizeof(dynamic_defs[0]);

////////////////////////////////////////////////////////////////////////////////

bool is_char_allowed_in_name(char c) {
	return ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '_' || ('0' <= c && c <= '9');
}

int parse_to_rpn(f64_stack& rpn, const char* input) {
	f64_stack operators;

	bool previousWasValue = false;
	bool looseMinus = true;
	// TODO: bool expectValue = true;

	u32 i = 0;
	while (true) {
		// omit any whitespace
		while (true) {
			const char c = input[i];
			if (c == ' ' || c == '\t') {
				i += 1;
				continue;
			}
			break;
		}

		// try read number
		{
			char c = input[i];
			if (c == '-' || c == '+') {
				if (previousWasValue) {
					goto not_a_number;
				}
				c = input[i + 1];
			}
			if (!isdigit(c)) {
				goto not_a_number;
			}

			f64 number;
			int ret = sscanf(input + i, "%lf", &number);
			if (ret > 0) {
				rpn.push(number);

				if (input[i] == '-') {
					i += 1;
				}

				// omit the number
				while (true) {
					const char c = input[++i];
					if (isdigit(c) || c == '.') {
						continue;
					}
					break;
				}

				previousWasValue = true;
				continue;
			}
		}

		not_a_number:
		char c = input[i];

		// handle bracket opening
		if (c == '(') {
			if (previousWasValue) {
				if (!special_f64(operators.peek()).is_dynamic()) {
					operators.push(special_f64::dynamic(op_def_multiply, 2));
				}
			}

			operators.push(special_f64::bracket(i));

			previousWasValue = false;
			looseMinus = true;
			i += 1;
			continue;
		}

		// handle bracket closing
		if (c == ')') {
			// find bracket matching opening bracket, pushing to output everything between
			bool found = false;
			special_f64 bracket;
			while (!operators.is_empty()) {
				bracket = operators.pop();
				if (bracket.is_bracket()) {
					found = true;
					break;
				}
				rpn.push(bracket);
			}
			if (!found) {
				printf("Error: Unmatched bracket closing! (offset=%u)\n", i);
				return 1;
			}

			// if there is function remaining, assume it was its arguments
			special_f64 fun = operators.peek();
			if (fun.is_dynamic() && fun.def->is_function()) {
				operators.index -= 1;
				if (previousWasValue) {
					bracket.args += 1;
				}
				fun.args = bracket.args;
				rpn.push(fun);
			}

			// move to next tokens
			looseMinus = false;
			previousWasValue = true;
			i += 1;
			continue;
		}

		// skip comma
		if (c == ',' || c == ';') {
			// push all operators to output, till bracket
			bool found = false;
			while (!operators.is_empty()) {
				special_f64 op = operators.peek();
				if (op.is_bracket()) {
					// increment args counter (in brackets specials on operators stack)
					op.args += 1;
					operators.values[operators.index] = op;
					found = true;
					break;
				}
				operators.index -= 1;
				rpn.push(op);
			}
			if (!found) {
				printf("Error: Comma outside brackets! (offset=%u)\n", i);
				return 1;
			}

			// move to next tokens
			previousWasValue = false;
			i += 1;
			continue;
		}

		// handle operators
		{
			// try match operator
			const op_def* found = nullptr;
			if (previousWasValue) {
				// associative (full/left-side) operators
				switch (c) {
					case '+': found = &op_def_add;        break;
					case '-': found = &op_def_subtract;   break;
					case '*': found = &op_def_multiply;   break;
					case '/': found = &op_def_divide;     break;
					case '%': found = &op_def_modulo;     break;
					case '^': found = &op_def_power;      break;
					case '!': found = &op_def_factorial;  break;
					default: break;
				}
				if (found) {
					const u8 priority = found->priority;

					if (looseMinus) {
						// handle loose minuses operation order
						if (priority > op_def_subtract.priority) {
							f64 value = rpn.peek();
							if (value < 0) {
								rpn.index -= 1;
								rpn.push(0);
								rpn.push(fabs(value));
								operators.push(special_f64::dynamic(op_def_subtract, 2));
							}
						}
					}

					// if any, push all higher or equal priority operators to output
					while (!operators.is_empty()) {
						const special_f64 op = operators.peek();
						if (op.is_bracket()) {
							break;
						}
						if (priority <= op.def->priority) {
							operators.index -= 1;
							rpn.push(op);
							continue;
						}
						break;
					}

					// then push the parsed operator to operators stack
					operators.push(special_f64::dynamic(*found, found->max_args));

					// move to next tokens
					previousWasValue = false;
					i += 1;
					continue;
				}
			}
			else {
				// right-side associative operators
				switch (c) {
					case '-': found = &op_def_neg; break;
					default: break;
				}
				if (found) {
					// push the parsed operator to operators stack
					operators.push(special_f64::dynamic(*found, found->max_args));

					// move to next tokens
					//previousWasValue = false; // already false
					i += 1;
					continue;
				}
			}
		}

		// try finding functions or constants
		{
			const op_def* found = nullptr;
			u8 nameLength;
			for (u8 fi = 0; fi < dynamic_defs_count; fi++) {
				u32 ini = i;
				u32 fni = 0;
				while (true) {
					char c = input[ini];
					char e = dynamic_defs[fi].name[fni];
					if (!e) {
						if (is_char_allowed_in_name(c)) {
							// there is more, fail
							break;
						}
						else {
							// end of name, match
							found = &dynamic_defs[fi];
							nameLength = fni;
							fi = 254;
							break;
						}
					}
					if (tolower(e) == tolower(c)) {
						ini += 1;
						fni += 1;
						continue;
					}
					break;
				}
			}
			if (found) {
				if (previousWasValue) {
					operators.push(special_f64::dynamic(op_def_multiply, 2));
				}

				operators.push(special_f64::dynamic(*found, 0)); // args count might be updated on closing bracket
				previousWasValue = true;
				i += nameLength;
				continue;
			}
		}

		// there might be variable
		{
			u8 j = i;
			while (true) {
				char c = input[j];
				if (is_char_allowed_in_name(c)) {
					j += 1;
					if (j - i > 6) {
						// if name longer than 6 characters, fail
						printf("Error: Variable name longer then 6 characters, unsupported. (offset=%u,name='%7s')\n", i, input + i);
						return 1;
					}
					continue;
				}
				break;
			}
			if (j > i) {
				if (previousWasValue) {
					operators.push(special_f64::dynamic(op_def_multiply, 2));
				}

				rpn.push(special_f64::variable(input + i, j - i));
				previousWasValue = true;
				i = j;
				continue;
			}
		}

		if (c == 0 || c == '\r' || c == '\n') {
			// end of input
			break;
		}

		// unknown token
		printf("Error: Unknown token! (offset=%u,code=%u,ascii='%c')\n", i, input[i], input[i]);
		return 1;
	}

	end_of_input:

	// move remaining operators to output
	while (!operators.is_empty()) {
		special_f64 value = operators.pop();
		if (value.is_bracket()) {
			printf("Error: Unmatched bracket beginning! (offset=%u)\n", value.offset);
			return 1;
		}
		rpn.push(value);
	}

	return 0;
}

f64 execute_rpn(const f64_stack& rpn) {
	f64_stack stack;
	
	for (u8 i = 0; i <= rpn.index; i++) {
		special_f64 value = rpn.values[i];
		if (value.is_dynamic()) {
			value.def->function(stack, value.args);
		}
		else {
			stack.push(value);
		}
	}

	return stack.peek();
}

inline f64 round_near_zero(f64 value) {
	return fabs(value) < 0.000000000001 ? 0 : value;
}

void print_rpn(const f64_stack& rpn) {
	for (u8 i = 0; i <= rpn.index; i++) {
		special_f64 value = rpn.values[i];
		if (value.is_dynamic()) {
			if (value.def->is_function()) {
				printf("%s#%u ", value.def->name, value.args);
			}
			else {
				printf("%s ", value.def->name);
			}
		}
		else if (value.is_variable()) {
			printf("$%s ", value.name);
		}
		else {
			printf("%.12lg ", round_near_zero(value.as_f64));
		}
	}
}

int main() {
	// printf("stdin = %p\n", stdin); // 754b4600
	f64_stack rpn;
	{
		// read input
		printf("Podaj wyrazenie: ");
		char input[255 + 1];
		fgets(input, 255 + 1, stdin);
		
		// parse RPN
		int ret = parse_to_rpn(rpn, input);
		if (ret) return ret;
	}

	// print out RPN
	printf("ONP: ");
	print_rpn(rpn);
	printf("\n");

	// check for variables
	bool has_variables = false;
	for (u8 i = 0; i <= rpn.index; i++) {
		special_f64 value = rpn.values[i];
		if (value.is_variable()) {
			has_variables = true;
			break;
		}
	}

	if (has_variables) {
		// loop: ask for variables, calculate, print, repeat (until EOF)
		while (true) {
			f64_stack rpn_live(rpn); // working on copy
			printf("\n");
			
			for (u8 i = 0; i <= rpn_live.index; i++) {
				special_f64 value = rpn_live.values[i];
				if (value.is_variable()) {
					printf("Podaj %.6s: ", value.name);

					char buffer[20];
					f64 input;
					if (!fgets(buffer, 20, stdin)) {
						goto end;
					}
					if (sscanf(buffer, "%lf", &input) <= 0) {
						goto end;
					}

					// replace all instances of the variable
					for (u8 j = i; j <= rpn_live.index; j++) {
						if (value == rpn_live.values[j]) {
							rpn_live.values[j] = input;
						}
					}
				}
			}

			// printf("ONP: ");
			// print_rpn(rpn_live);
			// printf("\n");

			f64 result = execute_rpn(rpn_live);
			printf("Wynik: %.12lg\n", round_near_zero(result));
		}

		end:
		printf("(koniec)\n");
	}
	else {
		// no variables, calculate and print result
		f64 result = execute_rpn(rpn);
		printf("Wynik: %.12lg\n", round_near_zero(result));
	}

	return 0;
}
