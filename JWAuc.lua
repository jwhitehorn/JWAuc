local frame, events = CreateFrame("FRAME"), {};
local secondsSinceLastAddOnEvent = 0
local version = "1.0"

--********** Event Handling **********--

function events:PLAYER_ENTERING_WORLD(...)
  print("JWAuc Version " .. version .." loaded");
  print("type '/script JWAucHelp()' for more information")
end

function OnFrameUpdate(self, elapsed)
    secondsSinceLastAddOnEvent = secondsSinceLastAddOnEvent + elapsed
    if secondsSinceLastAddOnEvent >= 10 then
		JWOnAddOnEvent()
        secondsSinceLastAddOnEvent = 0
    end
end

frame:SetScript("OnUpdate", OnFrameUpdate)
frame:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(events) do
 frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end

--********** Application Logic **********--
local isRunning = false
local allowBidding = false
local auctionsPerPage = 50
local targetUnitPrice = 2000
local itemToPurchase = "Silk Cloth"
local auctionSearchPage = 1
local numBatchAuctions, totalAuctions

--call this to start the automated auction processing
function JWAucStart()
	print("JWAuc: Starting...")
	isRunning = true
	auctionSearchPage = 1
	JWSimpleSearch(itemToPurchase, auctionSearchPage)
end

--call this to stop the automated auction processing
function JWAucStop()
	print("JWAuc: Stopping...")
	isRunning = false
end

--call this to change the targetUnitPrice (in copper)
function JWSetTargetUnitPrice(price)
	targetUnitPrice = price
end

--call this method (passing true or false) to enable or disable debug mode
function JWSetDebugMode(debugMode)
	if debugMode then
		print("JWAuc: Entering debug mode...")
	else
		print("JWAuc: Enter PRODUCTION mode...")
	end
	allowBidding = debugMode == false	--only allow bidding if we are NOT in debug mode
end

--a help function
function JWAucHelp()
	print("JWAuc: Help")
	print("   JWAuc version " .. version)
	--print("   Running: " .. isRunning)
	--print("   Item to purchase: " .. itemToPurchase)
	print("   Availble commands:")
	print("      JWAucStart()")
	print("      JWAucStop()")
	print("      JWAucSetTargetUnitPrice(price)")
	print("      JWAucSetDebugMode(debugMode)")
	print("      JWAucHelp()")
end

--called every 10 seconds, this is the main event loop for JWAuc
function JWOnAddOnEvent()
	if isRunning then
		if auctionSearchPage == 1 then
			numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
		end
		print("JWAuc: Processing page " .. auctionSearchPage)
		
		JWProcessItemsWithNameAndUnitPrice(itemToPurchase, targetUnitPrice)
		
		if totalAuctions <= auctionsPerPage * auctionSearchPage then
			auctionSearchPage = 0
		end
		auctionSearchPage = auctionSearchPage + 1
		JWSimpleSearch(itemToPurchase, auctionSearchPage);
	end
end

function JWSimpleSearch(query, page) 
  QueryAuctionItems(query, nil, nil, nil, nil, nil, page)
end

--returns an array of indexes into the current auction listing for items with:
--		Their name exactly equal to n
--      Their PER UNIT buyout price less than or equal to the specified n, desiredUnitPrice (in copper)
function JWProcessItemsWithNameAndUnitPrice(n, desiredUnitPrice)
	for i=1,auctionsPerPage do
		name, texture, count, quality, canUse, level, 
		levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("list", i)
		if name == nil then
			return result	--stop immeditly upon a nil name
		end
		if name == n and buyoutPrice > 0 then
			listingsUnitPrice = buyoutPrice / count
			if listingsUnitPrice <= desiredUnitPrice then
				print(name .. " count -> " .. count .. " buyout -> " .. buyoutPrice)
				if allowBidding then
					PlaceAuctionBid("list", i, buyoutPrice)
				end
			end
		end
	end
end