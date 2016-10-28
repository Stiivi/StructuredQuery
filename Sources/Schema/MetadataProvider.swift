/// Represents objects which provide metadata about schema, such as tables,
/// their columns.
public protocol MetadataProvider {
	/// Returns a table definition for table `name` in schema `schema`.
	func table(name: String, schema: String?) -> Table

	/// Returns `true` if table `name` exists in `schema`.
	func tableExists(name: String, schema: String?) -> Bool

	/// Returns list of table names in `schema`.
	func tableNames(schema: String?) -> [String]

	/// Returns list of table objects in `schema`.
	func tables(schema: String?) -> [Table]
}
