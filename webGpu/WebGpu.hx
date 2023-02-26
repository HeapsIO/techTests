import Api;

class WebGpu {

	var context : GPUCanvasContext;
	var device : GPUDevice;

	function new() {
	}

	function start() {
		var gpu = GPU.get();
		gpu.requestAdapter().then(function(adapt) {
			adapt.requestDevice().then(function(device) {
				this.device = device;
				init();
			});
		});
	}

	function init() {
		var canvas : js.html.CanvasElement = cast js.Browser.document.getElementById("webgpu");
		context = cast canvas.getContext("webgpu");
		context.configure({
			device : device,
			format : bgra8unorm,
			usage : (RENDER_ATTACHMENT:GPUTextureUsageFlags) | COPY_SRC,
			alphaMode: opaque,
		});

		var depthTex = device.createTexture({
			size : { width : canvas.width, height : canvas.height },
			dimension : d2,
			format : depth24plus_stencil8,
			usage : (RENDER_ATTACHMENT:GPUTextureUsageFlags) | COPY_SRC,
		});

		var colorTex = context.getCurrentTexture();
		var colorView = colorTex.createView();
		var depthView = depthTex.createView();

		var positions = new js.lib.Float32Array([
			1.0, -1.0, 0.0, -1.0, -1.0, 0.0, 0.0, 1.0, 0.0
		]);
		var colors = new js.lib.Float32Array([
			1.0,
			0.0,
			0.0,
			0.0,
			1.0,
			0.0,
			0.0,
			0.0,
			1.0
		]);
		var indices = new js.lib.Uint16Array([0, 1, 2]);

		var uniformData = new js.lib.Float32Array([
			// ♟️ ModelViewProjection Matrix (Identity)
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0,
			// 🔴 Primary Color
			0.9, 0.1, 0.3, 1.0,
			// 🟣 Accent Color
			0.8, 0.2, 0.8, 1.0,
		]);

		function createBuffer(arr:js.lib.ArrayBufferView,type) {
			var buf = device.createBuffer({
				size : (arr.byteLength + 3) & ~3,
				usage : type,
				mappedAtCreation :  true,
			});
			if( Std.isOfType(arr,js.lib.Uint16Array) )
				new js.lib.Uint16Array(buf.getMappedRange()).set(cast arr);
			else
				new js.lib.Float32Array(buf.getMappedRange()).set(cast arr);
			buf.unmap();
			return buf;
		}

		var posBuffer = createBuffer(positions, VERTEX);
		var colBuffer = createBuffer(colors, VERTEX);
		var indices = createBuffer(indices, INDEX);

		var uniformBuffer = createBuffer(uniformData, (UNIFORM:GPUBufferUsageFlags) | COPY_DST);

		var vertex = device.createShaderModule({ code : VERTEX_SRC });
		var fragment = device.createShaderModule({ code : FRAGMENT_SRC });

		var layout = device.createPipelineLayout({ bindGroupLayouts: [] });
		var pipeline = device.createRenderPipeline({
			layout : layout,
			vertex : { module : vertex, entryPoint : "main", buffers : [
				{
					attributes: [{ shaderLocation : 0, offset : 0, format : float32x3 }],
					arrayStride: 4 * 3,
					stepMode: GPUVertexStepMode.vertex
				},
				{
					attributes: [{ shaderLocation : 1, offset : 0, format : float32x3 }],
					arrayStride: 4 * 3, // sizeof(float) * 3
					stepMode: GPUVertexStepMode.vertex
				}
			]},
			fragment : { module : fragment, entryPoint : "main", targets : [{ format : bgra8unorm }] },
			primitive : { frontFace : cw, cullMode : none, topology : triangle_list },
			depthStencil : {
				depthWriteEnabled: true,
				depthCompare: less,
				format: depth24plus_stencil8
			}
		});

		var command = device.createCommandEncoder();

		var pass = command.beginRenderPass({
			colorAttachments : [{
				view : colorView,
				clearValue : { r : 1, g : 0, b : 1, a : 1 },
				loadOp : clear,
				storeOp: store
			}],
			depthStencilAttachment: {
				view : depthView,
				depthClearValue: 1,
				depthLoadOp: clear,
				depthStoreOp: store,
				stencilClearValue: 0,
				stencilLoadOp: clear,
				stencilStoreOp: store,
			},
		});

		pass.setPipeline(pipeline);
		pass.setViewport(0, 0, canvas.width, canvas.height, 0, 1);
		pass.setScissorRect(0, 0, canvas.width, canvas.height);
		pass.setVertexBuffer(0, posBuffer);
		pass.setVertexBuffer(1, colBuffer);
		pass.setIndexBuffer(indices, uint16);
		pass.drawIndexed(3);
		pass.end();

		device.queue.submit([command.finish()]);
	}

	static function main() {
		new WebGpu().start();
	}


	static var VERTEX_SRC_UNIFORM = "
	struct VSOut {
		@builtin(position) nds_position: vec4<f32>,
		@location(0) color: vec3<f32>,
	};

	struct UBO {
		modelViewProj: mat4x4<f32>,
		primaryColor: vec4<f32>,
		accentColor: vec4<f32>
	  };

	  @group(0) @binding(0)
	  var<uniform> uniforms: UBO;

	@vertex
	fn main(@location(0) in_pos: vec3<f32>,
			@location(1) in_color: vec3<f32>) -> VSOut {
		var vs_out: VSOut;
		vs_out.nds_position = uniforms.modelViewProj * vec4<f32>(inPos, 1.0);
		vs_out.color = inColor;
		return vs_out;
	}";

	static var VERTEX_SRC = "
	struct VSOut {
		@builtin(position) nds_position: vec4<f32>,
		@location(0) color: vec3<f32>,
	};

	@vertex
	fn main(@location(0) in_pos: vec3<f32>,
			@location(1) in_color: vec3<f32>) -> VSOut {
		var vs_out: VSOut;
		vs_out.nds_position = vec4<f32>(in_pos, 1.0);
		vs_out.color = in_color;
		return vs_out;
	}";

	static var FRAGMENT_SRC = "
	@fragment
	fn main(@location(0) in_color: vec3<f32>) -> @location(0) vec4<f32> {
		return vec4<f32>(in_color, 1.0);
	}";

}
