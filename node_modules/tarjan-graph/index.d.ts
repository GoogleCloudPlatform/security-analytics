interface Vertex {
	name: string;
	successors: Vertex[];
	index: number;
	lowLink: number;
	onStack: boolean;
	visited: boolean;
	reset: () => void;
}

declare class Graph {
	vertices: { [key: string]: Vertex };
	add(key: string, descendants: string[] | string): Graph;
	reset(): void;
	addAndVerify(key: string, descendants: string[] | string): Graph;
	dfs(key: string, visitor: (v: Vertex) => void): void;
	getDescendants(key: string): string[];
	hasCycle(): boolean;
	getStronglyConnectedComponents(): Vertex[][];
	getCycles(): Vertex[][];
	clone(): Graph;
	toDot(): string
}

export {
	Graph
}
