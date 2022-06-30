
const fs = require('fs');
const child_process = require('child_process');
const { describe, test } = global;
// describe = () => {}; test = () => {};

const file = 'main.asm.exe';
const precision = 9;

function run({expression, vars}) {
	try {
		let input = expression;
		if (Array.isArray(vars)) {
			if (Array.isArray(vars[0])) { // [['a', 1], ['b', 2], ...]
				input += '\n' + vars.map(v => v[1]).join('\n');
			}
			else { // [1, 2, ...]
				input += '\n' + vars.join('\n');
			}
		}

		const output = child_process.execFileSync(file, [], {
			input,
			maxBuffer: 8 * 1024,
			timeout: 1000,
		}).toString().replace(/\r\n/g, '\n');

		const askedVars = [...output.matchAll(/Podaj ([a-z0-9_]+)/gi)].slice(1).map(m => m[1]);
		if (askedVars.pop() != askedVars[0]) {
			console.warn(`First variable should be asked again before EOF is parsed, ignoring.`);
		}

		const resultString = output.match(/Wynik: (.*)/i)[1].toLowerCase();
		const result = (
			resultString.includes('inf') 
				? resultString.includes('-') 
					? -Infinity : Infinity
				: (resultString.includes('nan') || resultString.includes('ind'))
					? NaN
					: parseFloat(resultString)
		);

		return {
			result,
			rpn: output.match(/ONP: (.*)/i)[1].trim(),
			vars: askedVars,
		};
	}
	catch (e) {
		// console.log(e.stdout.toString());
		if (e.code == 'ENOBUFS') {
			throw new Error(`Too much output!`);
		}
		throw e;
	}
}

function myTest(expression, more) {
	if (typeof more == 'number') {
		test(`${expression} = ${more}`, () => {
			const o = run({expression});
			if (isNaN(o.result))
				expect(o.result).toBeNaN();
			else
				expect(o.result).toBeCloseTo(more, precision);
		});
	}
	else {
		let name = expression;
		if (more.vars) {
			if (Array.isArray(more.vars[0]))
				name += ` (for ${more.vars.map(([k, v]) => `${k}=${v}`).join(', ')})`;
			else
				name += ` (for ${more.vars.join(', ')})`;
		}
		name += `${typeof more.result == 'undefined' ? '' : ` = ${more.result}`}`;
		test(name, () => {
			const o = run({
				expression,
				vars: more.vars,
			});
			if (typeof more.result != 'undefined') {
				if (isNaN(o.result))
					expect(o.result).toBeNaN();
				else
					expect(o.result).toBeCloseTo(more.result, precision);
			}
			if (more.rpn) {
				expect(o.rpn).toEqual(more.rpn);
			}
			if (more.vars && Array.isArray(more.vars[0])) {
				expect(o.vars).toEqual(more.vars.map(v => v[0]));
			}
		});
	}
}

function myTestForError(expression, stdout, status) {
	test(expression, () => {
		let caught;
		try {
			run({expression});
		}
		catch (error) {
			caught = error;
		}

		expect(caught).toBeTruthy();
		expect(caught.message).toBeTruthy();
		expect(caught.message.match(/Command failed/i)).toBeTruthy();
		if (typeof status !== 'undefined') {
			expect(caught.status).toBe(status);
		}
		else {
			expect(caught.status).not.toBe(0);
		}

		expect(caught.stdout.toString()).toEqual(expect.stringContaining(stdout));
	});
}

// Run once outside tests, so malware protection can scan it ahead of time, 
// instead blocking it and causing test runner timeout
if (run({expression: '2+2'}).result != 4) {
	console.error('2+2 =/= 4!');
	process.exit(1);
}

////////////////////////////////////////////////////////////////////////////////

describe('Basics', () => {
	myTest('7', 7);
	myTest('-7', -7);
	myTest('- 7', -7);
	myTest('+1-1', 0);
	myTest('-1+1', 0);
	//myTest(' + 1 - 1', 0); // not really necessary, isn't it?
	myTest(' - 1 + 1', 0);
	myTest('-1-2-3', -6);
	myTest('2+3*4', 14);
	myTest('(2 + 3) * 4', 20);
	myTest('2(3*4)', 24);
	myTest('3 - (5 + 5) / 2', -2);
	myTest('((3*5))', 15);
	myTest('(((3*5)))', 15);
	myTest('4^2!', 16);
	myTest('-2^2', -4);
	myTest('(-2)^2', 4);
	myTest('1 / 0', Infinity);
	myTest('-1 / 0', -Infinity);
});

describe('Intermediate', () => {
	myTest('5*((3 - 7)*2 - 3*(5 + 1)) - 3', { result: -133, rpn: "5 3 7 - 2 * 3 5 1 + * - * 3 -" });
	myTest('max(4 + 3, (4 - 2), (-2^2))', { result: 7, rpn: "4 3 + 4 2 - 0 2 2 ^ - max#3" });
});

describe('Advanced', () => {
	// TODO: ...?
});

describe('Operators', () => {
	myTest('17+3', 20);
	myTest('17-3', 14);
	myTest('17*3', 51);
	myTest('17/3', 5.66666666667);
	myTest('17%3', 2);
	myTest('17^3', 4913);

	myTest('6!', 720);
	myTest('6.2!', 720);
});

describe('Functions', () => {
	myTest('abs(-3.21)', 3.21);
	myTest('sign(-3.21)', -1);
	myTest('ceil(-3.21)', -3);
	myTest('floor(-3.21)', -4);
	myTest('trunc(-3.21)', -3);
	myTest('round(-4.56)', -5);

	myTest('min(-9, 2, 0, 6, -1)', -9);
	myTest('max(-9, 2, 0, 6, -1)', 6);
	myTest('5+min(3, 4)', 8);
	myTest('sum(-9, 2, 0, 6, -1)', -2);
	myTest('product(-9, 2, 0, 6, -1)', 0);
	myTest('product(-9, 2, 6, -1)', 108);
	myTest('product(-9, 2, -inf, 6, -1)', -Infinity);
	myTest('count(-9, 2, 0, 6, -1)', 5);
	myTest('avg(-9, 2, 0, 6, -1)', -0.4);

	myTest('sqrt(2)', 1.4142135623730951);
	myTest('sqrt(9)', 3);
	myTest('cbrt(2)', 1.2599210498948732);
	myTest('cbrt(27)', 3);
	myTest('sqrt(-4)', NaN);

	myTest('rad(35)', 35 * (Math.PI / 180));
	myTest('deg(7pi/6)', 7 * Math.PI / 6 * (180 / Math.PI));

	myTest('sin(3)',  Math.sin(3));
	myTest('sin(pi)',  0);
	myTest('cos(3)',  Math.cos(3));
	myTest('tan(3)',  Math.tan(3));
	myTest('asin(0.3)', Math.asin(0.3));
	myTest('acos(0.3)', Math.acos(0.3));
	myTest('atan(0.3)', Math.atan(0.3));
	myTest('atan2(3,4)', Math.atan2(3, 4));

	myTest('exp(3)', Math.exp(3));
	myTest('ln(3)', Math.log(3));
	myTest('log(3)', Math.log(3));
	myTest('log(3, 10)', Math.log10(3));
	myTest('log10(3)', Math.log10(3));

	describe('Fibonacci', () => {
		myTest('fib(0)', 0);
		myTest('fib(1)', 1);
		myTest('fib(2)', 1);
		myTest('fib(3)', 2);
		myTest('fib(4)', 3);
		myTest('fib(5)', 5);
		myTest('fib(6)', 8);
		myTest('fib(9)', 34);
	});
});

describe('Constants', () => {
	myTest('pi', Math.PI);
	myTest('euler', Math.E);
	myTest('golden', 1.61803398875);

	myTest('inf', Infinity);
	myTest('-inf', -Infinity);
	myTest('nan', NaN);

	myTest('nr_albumu', 0x1CC35);
	test('unixtime', () => expect(run({expression: 'unixtime'}).result).toBeCloseTo(Math.floor(+new Date() / 1000), -1));

	myTest('2pi',      Math.PI * 2);
	myTest('1/3pi', 1 / (3 * Math.PI));
	myTest('1/3*pi', 1 / 3 * Math.PI);
	myTest('(1/3)pi', 1 / 3 * Math.PI);
	myTest('pi * 2', Math.PI * 2);
	myTest('2 * pi', Math.PI * 2);
	myTest('Euler', Math.E);
	myTest('EULER', Math.E);
	myTest('eUlEr', Math.E);
});

describe('Variables', () => {
	myTest('a+b', { vars: [['a', 5], ['b', 8]], result: 13 });
	myTest('a+A', { vars: [['a', 5], ['A', 8]], result: 13 });
	myTest('a*x^2 + b*x + c', { vars: [['a', 1], ['x', 0.5], ['b', 2], ['c', -2]], result: -0.75 })
});

describe('Errors', () => {
	myTestForError('123*(456+789', 'Unmatched bracket beginning');
	myTestForError('123*456+789)', 'Unmatched bracket closing');
	myTestForError('123, 456', 'Comma outside brackets');
	myTestForError('~!@#$%^&*()_+}{{":?><', 'Unknown token');
	myTestForError('2 + LZEASGT', 'Variable name longer then 6 characters');
	// TODO: mini fuzzy testing?
});

//if (false)
describe('Examples from external file', () => {
	const lines = fs.readFileSync('./examples.txt', { encoding: 'utf-8' })
		.split(/\r\n|\r|\n/)
		.map(line => line.replace(/#.*/, '').trim())
		.filter(line => !!line)
	;

	let i = 0;
	while (i < lines.length) {
		// Parametrized or simple
		const colon = lines[i].indexOf(':');
		if (colon > 0) {
			// Equality check or calculating values
			const equal = lines[i].indexOf('=');
			if (equal > 0) {
				const left = lines[i].substring(0, equal).trim();
				const right = lines[i].substring(lines[i].lastIndexOf('=') + 1, lines[i].lastIndexOf(':')).trim();
				while (true) {
					i += 1;
					if (!lines[i]) break;
					if (!lines[i].startsWith('for ') && !lines[i].startsWith('dla ')) break;
					const vars = lines[i].substring(4).split(',').map(v => parseFloat(v.trim()));
					test(`${left} == ${right} with (${vars.join(', ')})`, () => {
						// A little hacky way of enforcing the same order of variables, but will do.
						expect(run({expression: `(${left}) - (${right})`, vars}).result).toBeCloseTo(0);
					});
				}
			}
			else {
				const left = lines[i].substring(0, colon).trim();
				while (true) {
					i += 1;
					if (!lines[i]) break;
					if (!lines[i].startsWith('for ') && !lines[i].startsWith('dla ')) break;
					const equal = lines[i].indexOf('=');
					if (equal < 0) throw new Error('Expected variables then equal sign and expected value.');
					const vars = lines[i].substring(4, equal).split(',').map(v => parseFloat(v.trim()));
					const right = lines[i].substring(lines[i].lastIndexOf('=') + 1).trim();
					test(`${left} == ${right} with (${vars})`, () => {
						expect(run({expression: left, vars}).result)
							.toBeCloseTo(run({expression: right}).result);
					});
				}
			}
			continue;
		}
		else {
			const equal = lines[i].indexOf('=');
			if (equal > 0) {
				const left = lines[i].substring(0, equal).trim();
				const right = lines[i].substring(lines[i].lastIndexOf('=') + 1).trim();
				test(`${left} == ${right}`, () => {
					expect(run({expression: left}).result)
						.toBeCloseTo(run({expression: right}).result);
				});
				i += 1;
				continue;
			}
		}
		i += 1;
	}
});
