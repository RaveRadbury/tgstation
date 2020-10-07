/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "paper"
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1



/obj/item/teleportation_scroll/attack_self(mob/user)
	user.set_machine(src)
	var/dat = "<B>Teleportation Scroll:</B><BR>"
	dat += "Number of uses: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Four uses, use them wisely:</B><BR>"
	dat += "<A href='byond://?src=[REF(src)];spell_teleport=1'>Teleport</A><BR>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/item/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || src.loc != usr)
		return
	if (!ishuman(usr))
		return 1
	var/mob/living/carbon/human/H = usr
	if(H.is_holding(src))
		H.set_machine(src)
		if (href_list["spell_teleport"])
			if(uses)
				teleportscroll(H)
	if(H)
		attack_self(H)
	return

/obj/item/teleportation_scroll/proc/teleportscroll(mob/user)

	var/A

	A = input(user, "Area to jump to", "BOOYEA", A) as null|anything in GLOB.teleportlocs
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !A || !uses)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(2, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.is_blocked_turf())
			L += T

	if(!L.len)
		to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return

	if(do_teleport(user, pick(L), forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		smoke.start()
		uses--
	else
		to_chat(user, "The spell matrix was disrupted by something near the destination.")

/obj/item/teleportation_scroll/no_smoke
	uses = 9

/obj/item/teleportation_scroll/no_smoke/teleportscroll(mob/user) // /area/hydroponics/garden/cornlabyrinth

	var/A
	var/list/acceptable_locations = GLOB.teleportlocs
	for(var/L in acceptable_locations)
		var/area/T = acceptable_locations[L]
		if(istype(T, /area/security) || istype(T, /area/shuttle/arrival) || istype(T, /area/crew_quarters/dorms) || istype(T, /area/hydroponics/garden/cornmaze) || istype(T, /area/awaymission/cabin/snowforest/forest)) // areas you aren't allowed to teleport to
			acceptable_locations -= L

	A = input(user, "Area to jump to", "*citrus laugh*", A) as null|anything in acceptable_locations
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !A || !uses)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.is_blocked_turf())
			L += T

	if(!L.len)
		to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return

	if(do_teleport(user, pick(L), forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		uses--
	else
		to_chat(user, "The spell matrix was disrupted by something near the destination.")