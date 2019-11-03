static int g_iModelOverrideRef[TF_MAXPLAYERS+1][2];
static char g_sModelOverrideModel[TF_MAXPLAYERS+1][PLATFORM_MAX_PATH];

methodmap CModelOverride < SaxtonHaleBase
{
	public CModelOverride(CModelOverride ability)
	{
		g_iModelOverrideRef[ability.iClient][0] = 0;
		g_iModelOverrideRef[ability.iClient][1] = 0;
	}
	
	public void SetModel(char[] sModel)
	{
		strcopy(g_sModelOverrideModel[this.iClient], sizeof(g_sModelOverrideModel[]), sModel);
	}
	
	public int CreateProp()
	{
		int iProp = CreateEntityByName("prop_dynamic_override");
		if (IsValidEntity(iProp))
		{
			SetEntProp(iProp, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_WEAPON);
			SetEntProp(iProp, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_PARENT_ANIMATES);
			DispatchKeyValue(iProp, "model", g_sModelOverrideModel[this.iClient]);
			
			DispatchSpawn(iProp);
			ActivateEntity(iProp);
			AcceptEntityInput(iProp, "Start");
			
			PrintToChatAll("created prop %s", g_sModelOverrideModel[this.iClient]);
			
			return iProp;
		}
		
		return -1;
	}
	
	public void OnSpawn()
	{
		//We need to create 2 props to make this work. iModel[0] parented to iModel[1] parented to client
		int iModel[2];
		iModel[0] = this.CreateProp();
		iModel[1] = this.CreateProp();
		
		PrintToChatAll("%d %d", iModel[0], iModel[1]);
		
		if (!IsValidEntity(iModel[0]) || !IsValidEntity(iModel[1]))
			return;
		
		SetVariantString("!activator");
		AcceptEntityInput(iModel[0], "SetParent", iModel[1]);
		
		SetVariantString("head");
		AcceptEntityInput(iModel[0], "SetParentAttachment");
		
		SetVariantString("!activator");
		AcceptEntityInput(iModel[1], "SetParent", this.iClient);
		
		SetVariantString("head");
		AcceptEntityInput(iModel[1], "SetParentAttachment");
		
		g_iModelOverrideRef[this.iClient][0] = EntIndexToEntRef(iModel[0]);
		g_iModelOverrideRef[this.iClient][1] = EntIndexToEntRef(iModel[1]);
		SetEntityRenderMode(this.iClient, RENDER_NONE);
	}
	
	public void Destroy()
	{
		SetEntityRenderMode(this.iClient, RENDER_NORMAL);
	}
}