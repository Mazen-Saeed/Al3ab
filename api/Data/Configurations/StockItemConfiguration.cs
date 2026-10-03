using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class StockItemConfiguration : IEntityTypeConfiguration<StockItem>
{
    public void Configure(EntityTypeBuilder<StockItem> builder)
    {
        // No check on on_hand: an offline sale must never be rejected, so it may go below 0.
        builder.ToTable(t => t.HasCheckConstraint("ck_stock_items_low_stock_at", "low_stock_at IS NULL OR low_stock_at >= 0"));
    }
}
