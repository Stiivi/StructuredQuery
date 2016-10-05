// Mapping between operator names and their default compilation strings
public let DefaultBinaryOperators: [String:String] = [
	"add": "+",
	"sub": "-",
	"mul": "*",
	"div": "/",
	"mod": "%",
	"exp": "^",

	"bitand": "&",
	"bitor": "|",
	"bitxor": "#",
	"shl": "<<",
	"shr": ">>",

	"and": "AND",
	"or": "OR",

	"eq": "=",
	"ne": "!=",
	"lt": "<",
	"le": "<=",
	"gt": ">",
	"ge": ">=",

	"concat": "||",
	"like": "LIKE",

	"in": "IN",
	"notin": "NOT IN"
]

public let DefaultUnaryOperators: [String:String] = [
	"neg": "-",
	"not": "NOT",
	"bitnot": "~",
	"exists": "EXISTS",
	"distinct": "DISTINCT",
	"any": "ANY"
]

// TODO: affinity to argument (space/no space) as in "-1" vs "NOT x"
