total_count = @listings.cheap_total_count
json.listingsCount total_count
json.totalPages total_count / 25
json.searchParams search_params
json.maxCountForBestDealSort Listing::MAX_FOR_BEST_DEAL_SORT

if @listings.respond_to?(:current_page)
 json.currentPage @listings.current_page
else
  json.currentPage (params[:page] ? params[:page] : 1)
end

json.listings do
  json.partial! 'api/listings/listing', collection: @listings, as: :listing
end