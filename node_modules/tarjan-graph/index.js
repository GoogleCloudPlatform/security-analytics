class Vertex {
	constructor(name, successors) {
		this.name = name;
		this.successors = successors;
		this.reset();
	}

	reset() {
		this.index = -1;
		this.lowLink = -1;
		this.onStack = false;
		this.visited = false;
	}
}


class Graph {
	constructor() {
		this.vertices = {};
	}

	add(key, descendants) {
		descendants = Array.isArray(descendants) ? descendants : [descendants];

		const successors = descendants.map((key) => {
			if (!this.vertices[key]) {
				this.vertices[key] = new Vertex(key, []);
			}
			return this.vertices[key];
		});

		if (!this.vertices[key]) {
			this.vertices[key] = new Vertex(key);
		}

		this.vertices[key].successors = successors.concat([]).reverse();
		return this;
	}

	reset() {
		Object.keys(this.vertices).forEach((key) => {
			this.vertices[key].reset();
		});
	}

	addAndVerify(key, descendants) {
		this.add(key, descendants);
		const cycles = this.getCycles();
		if (cycles.length) {
			let message = `Detected ${cycles.length} cycle${cycles.length === 1 ? '' : 's'}:`;
			message += '\n' + cycles.map((scc) => {
				const names = scc.map(v => v.name);
				return `  ${names.join(' -> ')} -> ${names[0]}`;
			}).join('\n');

			const err = new Error(message);
			err.cycles = cycles;
			throw err;
		}

		return this;
	}

	dfs(key, visitor) {
		this.reset();
		const stack = [this.vertices[key]];
		let v;
		while (v = stack.pop()) {
			if (v.visited) {
				continue;
			}

			//pre-order traversal
			visitor(v);
			v.visited = true;

			v.successors.forEach(w => stack.push(w));
		}
	}

	getDescendants(key) {
		const descendants = [];
		let ignore = true;
		this.dfs(key, (v) => {
			if (ignore) {
				//ignore the first node
				ignore = false;
				return;
			}
			descendants.push(v.name);
		});

		return descendants;
	}

	hasCycle() {
		return this.getCycles().length > 0;
	}

	getStronglyConnectedComponents() {
		const V = Object.keys(this.vertices).map((key) => {
			this.vertices[key].reset();
			return this.vertices[key];
		});

		let index = 0;
		const stack = [];
		const components = [];

		const stronglyConnect = (v) => {
			v.index = index;
			v.lowLink = index;
			index++;
			stack.push(v);
			v.onStack = true;

			v.successors.forEach((w) => {
				if (w.index < 0) {
					stronglyConnect(w);
					v.lowLink = Math.min(v.lowLink, w.lowLink);
				} else if (w.onStack) {
					v.lowLink = Math.min(v.lowLink, w.index);
				}
			});

			if (v.lowLink === v.index) {
				const scc = [];
				let w;
				do {
					w = stack.pop();
					w.onStack = false;
					scc.push(w);
				} while (w !== v);

				components.push(scc);
			}
		};

		V.forEach(function(v) {
			if (v.index < 0) {
				stronglyConnect(v);
			}
		});

		return components;
	}

	getCycles() {
		return this.getStronglyConnectedComponents().filter((scc) => {
			if (scc.length > 1) {
				return true;
			}

			const startNode = scc[0];
			return startNode && startNode.successors.some(node => node === startNode);
		});
	}

	clone() {
		const graph = new Graph();

		Object.keys(this.vertices).forEach((key) => {
			const v = this.vertices[key];
			graph.add(v.name, v.successors.map((w) => {
				return w.name;
			}));
		});

		return graph;
	}

	toDot() {
		const V = this.vertices;
		const lines = [ 'digraph {' ];

		this.getCycles().forEach((scc, i) => {
			lines.push('  subgraph cluster' + i + ' {');
			lines.push('    color=red;');
			lines.push('    ' + scc.map(v => v.name).join('; ') + ';');
			lines.push('  }');
		});

		Object.keys(V).forEach((key) => {
			const v = V[key];
			if (v.successors.length) {
				v.successors.forEach((w) => {
					lines.push(`  ${v.name} -> ${w.name}`);
				});
			}
		});

		lines.push('}');
		return lines.join('\n') + '\n';
	}
}

module.exports = Graph;
