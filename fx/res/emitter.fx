{
	"type": "fx",
	"duration": 5,
	"cullingRadius": 3,
	"children": [
		{
			"type": "object",
			"name": "root",
			"children": [
				{
					"type": "emitter",
					"name": "emitter",
					"props": {
						"lifeTime": 3,
						"warmUpTime": 5,
						"alignMode": "Screen",
						"instSpeed": [
							0,
							0,
							1
						]
					},
					"children": [
						{
							"type": "polygon",
							"name": "polygon",
							"kind": 0,
							"args": [
								0
							],
							"children": [
								{
									"type": "material",
									"name": "material",
									"props": {
										"PBR": {
											"mode": "BeforeTonemapping",
											"blend": "Alpha",
											"shadows": false,
											"culling": "Back",
											"colorMask": 255
										},
										"Default": {
											"kind": "Opaque",
											"shadows": false,
											"culling": false,
											"light": false
										}
									}
								}
							]
						},
						{
							"type": "material",
							"name": "material",
							"props": {
								"PBR": {
									"mode": "BeforeTonemapping",
									"blend": "Alpha",
									"shadows": false,
									"culling": "Back",
									"colorMask": 255
								},
								"Default": {
									"kind": "Opaque",
									"shadows": false,
									"culling": false,
									"light": false
								}
							}
						}
					]
				}
			]
		}
	]
}