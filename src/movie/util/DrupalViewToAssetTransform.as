package movie.util
{
	public class DrupalViewToAssetTransform implements IDataTransform
	{
		public function DrupalViewToAssetTransform()
		{
		}
		
		public function transform(data:Object):Object {
			
			var returnObject = new Object();
			returnObject.type = ucfirst(data.node_data_field_asset_type_field_asset_type_value);
			returnObject.name = data.node_title;
			if (data.files_node_data_field_thumbnail_filepath)
			{
				returnObject.thumbnail = "/"+data.files_node_data_field_thumbnail_filepath;
			}
			if (data.files_node_data_field_thumbnail_roll_filepath)
			{
				returnObject.thumbnailRoll = "/"+data.files_node_data_field_thumbnail_roll_filepath;
			}
			returnObject.properties = {"assetPath":"/"+data.files_node_data_field_asset_file_filepath};
			
			if (data.node_data_field_asset_type_field_fullscreen_value=='true') {
				returnObject.properties.fullscreen = true;
			}
			
			if (data.node_data_field_asset_type_field_maintain_aspect_value=='true') {
				returnObject.maintainAspectRatio = true;
			}
		
			return returnObject;
		}

	}
}