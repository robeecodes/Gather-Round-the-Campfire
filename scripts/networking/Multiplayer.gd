extends Node

### Noray connection implementation based on Salodo (2025) - see 'Code References' in the README
### LAN connection implementation based on curtjs (2025) - see 'Code References' in the README
signal noray_connected
signal hosted
signal joined
signal join_failed
 
const NORAY_ADDRESS = "tomfol.io"
const NORAY_PORT = 8890
 
var is_host = false
var external_oid := ""

var err := OK
 
func config_noray():
	Noray.on_connect_to_host.connect(on_noray_connected)
	Noray.on_connect_nat.connect(handle_nat_connection)
	Noray.on_connect_relay.connect(handle_relay_connection)
 
	Noray.connect_to_host(NORAY_ADDRESS,NORAY_PORT)
 
func on_noray_connected():
	print("Connected to noray")
 
	Noray.register_host()
	await Noray.on_pid
	Noray.register_remote()
 
	noray_connected.emit()
 
func host(mode: String, IP: String):
	print("Hosting...",)
	if mode == "noray":
		config_noray()
		
		await noray_connected
		
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(Noray.local_port)
		multiplayer.multiplayer_peer = peer
		
		external_oid = Noray.oid
		print(external_oid)
	else:
		var peer := ENetMultiplayerPeer.new()
		peer.set_bind_ip(IP)
		peer.create_server(25565)
		multiplayer.multiplayer_peer = peer
	
	is_host = true
 
	hosted.emit()
 
func join(mode, oid):
	if mode == "noray":
		config_noray()
		
		await noray_connected
		
		Noray.connect_nat(oid)
		external_oid = oid
	 
		if err == OK:
			joined.emit()
		else:
			join_failed.emit()
	else:
		var peer := ENetMultiplayerPeer.new()
		peer.create_client(oid, 25565)
		multiplayer.multiplayer_peer = peer
		joined.emit()
 
func get_local_ip() -> String:
	var ip = ""
	
	for address in IP.get_local_addresses():
		if address.begins_with("192.168") or address.begins_with("10.") or address.begins_with("172."):
			ip = address
			break
	return ip

func handle_nat_connection(address,port):
	err = await connect_to_server(address, port)
 
	if err != OK && !is_host:
		print("NAT failed, using relay")
		Noray.connect_relay(external_oid)
		err = OK
 
	return err
 
func handle_relay_connection(address,port):
	return await connect_to_server(address,port)
 
func connect_to_server(address,port):
	err = OK
 
	if !is_host:
		var udp = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_dest_address(address,port)
 
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()
 
		if err != OK:
			if err == ERR_BUSY:
				print("Handshake to %s:%s succeeded partially, attempting connection anyway" % [address, port])
			else:
				print("Handshake to %s:%s failed: %s" % [address, port, error_string(err)])
				return err
		else:
			print("Handshake to %s:%s succeeded" % [address, port])
 
		var peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address,port, 0, 0, 0, Noray.local_port)
 
		if err != OK:
			return err
 
		multiplayer.multiplayer_peer = peer
 
		return OK
	else:
		err = await PacketHandshake.over_enet(multiplayer.multiplayer_peer.host,address,port)
 
	return err
