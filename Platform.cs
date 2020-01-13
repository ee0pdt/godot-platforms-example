using Godot;
using System;
using Platforms.Enums;

namespace Platforms
{

	public class Platform : Spatial
	{
		private float timePassed = 0.0f;
		private float totalTime = 2.0f;
		private Vector3 initialPosition;
		private Vector3 endVector;
		private Vector3 startVector;
		private Vector3 directionVector;
		private CSGBox geometryModel;
		private Spatial startPosition;
		private Spatial endPosition;
		private Target currentTarget = Target.end;
		private Mode selectMode = Mode.auto;
		private bool isActive = true;

		private void _onetime_setup()
		{
			//Empty implementation for the time being, until the tool aspect 
			//integration of Mono with Godot is discovered
		}

		private void _initialize(float _totalTime = 0.0f)
		{
			timePassed = 0.0f;
			if (_totalTime >= 0.1f)
				this.totalTime = _totalTime;
			startPosition = this.GetNodeOrNull<Spatial>("StartPosition");
			endPosition = this.GetNodeOrNull<Spatial>("EndPosition");
			geometryModel = this.GetNodeOrNull<CSGBox>("Geometry");
			startVector = startPosition.Translation;
			endVector = endPosition.Translation;
			GD.Print($"Platform, _initialize() called, geometry={geometryModel}");
			if (geometryModel != null)
			{
				geometryModel.Visible = true;
				if (currentTarget == Target.end)
				{
					directionVector = endVector - startVector;
					geometryModel.Translation = startVector;
				}
				else
				{
					directionVector = startVector - endVector;
					geometryModel.Translation = endVector;
				}
				initialPosition = geometryModel.Translation;
			}
		}

		public override void _Ready()
		{
			_onetime_setup();
			_initialize();
		}

		private void _process_movement(float delta)
		{
			timePassed += delta;
			var percentComplete = timePassed / totalTime;
			if (geometryModel != null)
			{
				//GD.Print($"Platform, _process_movement() called, geometry={geometryModel}, delta={delta}, % complete={percentComplete}");
				geometryModel.Translation = initialPosition + (directionVector * new Vector3(percentComplete, percentComplete, percentComplete));
				if (percentComplete >= 1.0f)
				{
					if (selectMode == Mode.auto)
					{
						if (currentTarget == Target.start)
							currentTarget = Target.end;
						else
							currentTarget = Target.start;
						_initialize();
					}
					else
						isActive = false;
				}
			}
		}

		public override void _Process(float delta)
		{
			if (isActive)
				_process_movement(delta);
		}
	}
}
