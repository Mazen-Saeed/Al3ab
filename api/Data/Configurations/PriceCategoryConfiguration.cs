using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class PriceCategoryConfiguration : IEntityTypeConfiguration<PriceCategory>
{
    public void Configure(EntityTypeBuilder<PriceCategory> builder)
    {
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_price_categories_single", "single_hourly_price >= 0");
            t.HasCheckConstraint("ck_price_categories_multi", "multi_hourly_price >= 0");
        });
    }
}
