extends CanvasLayer

func _ready():
	for i in range(5):
		if Global.armas[i]==true:
			if i==0:
				$ITEM/tarjeta1/comprar1.disabled=true
			elif i==1:
				$ITEM/tarjeta2/comprar2.disabled=true
			elif i==2:
				$ITEM/tarjeta3/comprar3.disabled=true
			elif i==3:
				$ITEM/tarjeta4/comprar4.disabled=true
			elif i==4:
				$ITEM/tarjeta5/comprar5.disabled=true


func _process(delta):
	$moneda/cant.text=str(Global.moneda)

func _on_comprar2_pressed():
	if Global.moneda>=30:
		Global.armas[1]=true
		$ITEM/tarjeta2/comprar2.disabled=true
		Global.moneda-=30
		$moneda/cant.text=str(Global.moneda)
	else:
		$noplata.visible=true
		yield(get_tree().create_timer(1), "timeout")		
		$noplata.visible=false

func _on_comprar3_pressed():
	if Global.moneda>=50:
		Global.armas[2]=true
		$ITEM/tarjeta3/comprar3.disabled=true
		Global.moneda-=50
		$moneda/cant.text=str(Global.moneda)
	else:
		$noplata.visible=true
		yield(get_tree().create_timer(1), "timeout")		
		$noplata.visible=false

func _on_comprar4_pressed():
	if Global.moneda>=70:
		Global.armas[3]=true
		$ITEM/tarjeta4/comprar4.disabled=true
		Global.moneda-=70
		$moneda/cant.text=str(Global.moneda)
	else:
		$noplata.visible=true
		yield(get_tree().create_timer(1), "timeout")		
		$noplata.visible=false

func _on_comprar5_pressed():
	if Global.moneda>=100:
		Global.armas[4]=true
		$ITEM/tarjeta5/comprar5.disabled=true
		Global.moneda-=100
		$moneda/cant.text=str(Global.moneda)
	else:
		$noplata.visible=true
		yield(get_tree().create_timer(1), "timeout")		
		$noplata.visible=false
